#!/bin/bash
set -e

#_______________________________________________________________________________
#                              Configurations
ZIP_FLAVOUR=${1:-'microg'} #default to microg

ZIP_PREFIX="$ZIP_FLAVOUR"
CONFIG_FILE="${ZIP_FLAVOUR}_config.txt"

ADDOND_FILE='70-microg.sh' #common to all flavours

## Repositories
declare -A REPO_BASE_URLS=(['fdroid']='https://f-droid.org/repo' ['microg']='https://microg.org/fdroid/repo')

#_______________________________________________________________________________
#                                 functions
function fail() {
  echo Failed. >&2
  exit 1 # Sometimes cannot exit (e.g. `$(...)`)
}

function fetch() {
  local URL="$1"
  local FILENAME="$2"

  curl --output "$FILENAME" "$URL" || fail
}

function download_repo_index() {
  local DL_URL="${REPO_BASE_URLS[$1]}/index.xml"
  local FILE_NAME="$1_index.xml"

  fetch "$DL_URL" "$FILE_NAME"
}

function xpath_exec() {
  local INDEX_FILE="$1"
  local XPATH_CMD="$2"
  local ret=""

  xmlstarlet select -t -v "$XPATH_CMD" "$INDEX_FILE" | {
    read ret || fail
    read && fail
    echo "$ret"
  }
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

  local REPO_URL="${REPO_BASE_URLS[$REPO_NAME]}"

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

  mkdir --parents "$DL_PATH" || fail
  fetch "$DL_URL" "$DL_FILE"
}

function generate_zip() {
  local ZIP_NAME="$1_$(date +%Y-%m-%d).zip"

  local ZIP_FILES=./*

  zip \
  --quiet \
  --recurse-path $ZIP_NAME \
  $ZIP_FILES \
  --exclude '*.asc' '*_index.xml' '*_config.txt' 'templates/*' || fail
  echo "Result: $ZIP_NAME"
}

#_______________________________________________________________________________
#                                 Main
echo "~~~ Downloading repo indexes"
for repo in "${!REPO_BASE_URLS[@]}"; do
  download_repo_index "$repo"
done

echo "~~~ Downloading apps and Making OTA survival script"
function download_app_extern() {
    download_app "$@"
    local PATH="${4##/system/}"
    echo "$PATH/$3.apk" >> "$ADDOND_FILE"
    echo "$PATH/$3/$3.apk" >> "$ADDOND_FILE"
}
for repo in "${!REPO_BASE_URLS[@]}"; do
  eval "$repo(){ download_app_extern \"$repo\" \"\$@\"; }"
done
cat templates/addond-head > "$ADDOND_FILE"
. "$CONFIG_FILE"
cat templates/addond-tail >> "$ADDOND_FILE"

echo "~~~ Packing up"
generate_zip "$ZIP_PREFIX"

echo "~~~ Cleaning up"
for repo in "${!REPO_BASE_URLS[@]}"; do
  rm --verbose "$repo_index.xml"
done
rm --verbose --recursive system/
rm --verbose "$ADDOND_FILE"

echo "~~~ Finished"
