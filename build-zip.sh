#!/bin/bash
set -e

#_______________________________________________________________________________
#                              Configurations
ZIP_FLAVOUR=${1:-'microg'} #default to microg

ZIP_PREFIX="$ZIP_FLAVOUR"
CONFIG_FILE="${ZIP_FLAVOUR}_config.txt"

ADDOND_FILE='70-microg.sh' #common to all flavours

#_______________________________________________________________________________
#                             Exported functions
function fetch() {
  local URL="$1"
  local FILENAME="$2"

  curl --output "$FILENAME" "$URL"
}

## Repositories
function get_repo_base_url() {
  case $1 in
    'fdroid' )
      local BASE_URL='https://f-droid.org/repo'
      ;;
    'microg' )
      local BASE_URL='https://microg.org/fdroid/repo'
      ;;
  esac

  echo $BASE_URL
}

function download_repo_index() {
  local DL_URL="$(get_repo_base_url "$1")/index.xml"
  local FILE_NAME="$1_index.xml"

  fetch "$DL_URL" "$FILE_NAME"
}

function xpath_exec() {
  local INDEX_FILE="$1"
  local XPATH_CMD="$2"

  xmlstarlet select -t -v "$XPATH_CMD" "$INDEX_FILE" | head -1
}

## Applications
function get_stable_version() {
  local INDEX_FILE="$1"
  local PACKAGE_ID="$2"

  xpath_exec "$INDEX_FILE" "/fdroid/application[@id = '$PACKAGE_ID']/marketversion"
}

function get_app_filename() {
  local INDEX_FILE="$1_index.xml"
  local PACKAGE_ID="$2"
  local XML_QUALIFICATION="$3"

  local VERSION="$(get_stable_version "$INDEX_FILE" "$PACKAGE_ID")"

  xpath_exec "$INDEX_FILE" "/fdroid/application[@id = '$PACKAGE_ID']/package[version = '$VERSION']$XML_QUALIFICATION/apkname"
}

function get_app_download_url() {
  local REPO_NAME="$1"
  local PACKAGE_ID="$2"
  local XML_QUALIFICATION="$3"

  local REPO_URL="$(get_repo_base_url "$REPO_NAME")"

  echo "$REPO_URL/$(get_app_filename "$REPO_NAME" "$PACKAGE_ID" "$XML_QUALIFICATION")"
}

function download_app() {
  local REPO_NAME="$1"
  local PACKAGE_ID="$2"
  local APK_NAME="$3"
  local INSTALL_PATH="$4"
  local NATIVECODE="$5"
  local XML_QUALIFICATION=""
  
  [ -n "$NATIVECODE" ] && XML_QUALIFICATION="[nativecode = '$NATIVECODE']"

  local DL_URL="$(get_app_download_url "$REPO_NAME" "$PACKAGE_ID" "$XML_QUALIFICATION")"
  local DL_PATH="./$INSTALL_PATH/$APK_NAME"
  local DL_FILE="$DL_PATH/$APK_NAME.apk"

  mkdir -p "$DL_PATH"
  fetch "$DL_URL" "$DL_FILE"
  #fetch $DL_URL.asc $DL_FILE.asc
}

#_______________________________________________________________________________
#                              Inner functions
function generate_zip() {
  local ZIP_NAME="$1_$(date +%Y-%m-%d).zip"

  local ZIP_FILES=./*

  zip \
  --quiet \
  --recurse-path $ZIP_NAME \
  $ZIP_FILES \
  --exclude '*.asc' '*_index.xml' '*_config.txt' 'templates/*'
  echo "Result: $ZIP_NAME"
}

#_______________________________________________________________________________
#                                 Main
echo "~~~ Downloading repo indexes"
download_repo_index fdroid
download_repo_index microg

echo "~~~ Downloading apps"
fdroid() {
  download_app fdroid "$@"
}
microg() {
  download_app microg "$@"
}
. "$CONFIG_FILE"

echo "~~~ Making OTA survival script"
cat templates/addond-head > $ADDOND_FILE
apps_config | awk '{sub("/system/", "", $4); printf "%1$s/%2$s.apk\n%1$s/%2$s/%2$s.apk\n", $4, $3}' >> $ADDOND_FILE
cat templates/addond-tail >> $ADDOND_FILE

echo "~~~ Packing up"
generate_zip $ZIP_PREFIX

echo "~~~ Cleaning up"
apps_config | awk '{print $1 "_index.xml"}' | uniq | xargs -l rm --verbose
rm --verbose -r system/
rm --verbose $ADDOND_FILE

echo "~~~ Finished"
