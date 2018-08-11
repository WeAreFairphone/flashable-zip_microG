#!/bin/bash
set -e

#_______________________________________________________________________________
#                              Configurations
ZIP_FLAVOUR=${1:-'microg'} #default to microg

ZIP_PREFIX="$ZIP_FLAVOUR"
CONFIG_FILE="${ZIP_FLAVOUR}_config.txt"

ADDOND_FILE='70-microg.sh' #common to all flavours

apps_config() {
  sed -e '/^#/d' "$CONFIG_FILE"
}

#_______________________________________________________________________________
#                             Exported functions
function fetch() {
  local URL=$1
  local FILENAME=$2

  wget \
  --no-verbose \
  --output-document=$FILENAME \
  $URL
} && export -f fetch

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
} && export -f get_repo_base_url

function download_repo_index() {
  local DL_URL="$(get_repo_base_url $1)/index.xml"
  local FILE_NAME="$1_index.xml"

  fetch $DL_URL $FILE_NAME
} && export -f download_repo_index

function xpath_exec() {
  local INDEX_FILE=$1
  local XPATH_CMD="$2"

  xmlstarlet select -t -v "$XPATH_CMD" $INDEX_FILE
} && export -f xpath_exec

## Applications
function get_stable_versioncode() {
  local INDEX_FILE=$1
  local PACKAGE_ID=$2

  xpath_exec $INDEX_FILE "/fdroid/application[@id = '$PACKAGE_ID']/marketvercode"
} && export -f get_stable_versioncode

function get_app_filename() {
  local INDEX_FILE="$1_index.xml"
  local PACKAGE_ID=$2

  local VERSION_CODE=$(get_stable_versioncode $INDEX_FILE $PACKAGE_ID)

  xpath_exec $INDEX_FILE "/fdroid/application[@id = '$PACKAGE_ID']/package[versioncode = '$VERSION_CODE']/apkname"
} && export -f get_app_filename

function get_app_download_url() {
  local REPO_NAME=$1
  local PACKAGE_ID=$2

  local REPO_URL=$(get_repo_base_url $REPO_NAME)

  echo "$REPO_URL/$(get_app_filename $REPO_NAME $PACKAGE_ID)"
} && export -f get_app_download_url

function download_app() {
  local REPO_NAME=$1
  local PACKAGE_ID=$2
  local APK_NAME=$3
  local INSTALL_PATH=$4

  local DL_URL=$(get_app_download_url $REPO_NAME $PACKAGE_ID)
  local DL_PATH=${INSTALL_PATH:1}/$APK_NAME
  local DL_FILE=$DL_PATH/$APK_NAME.apk

  mkdir --parents $DL_PATH
  fetch $DL_URL $DL_FILE
  #fetch $DL_URL.asc $DL_FILE.asc
} && export -f download_app

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
apps_config | awk '{print $1}' | uniq | xargs -l bash -c 'download_repo_index $@' -

echo "~~~ Downloading apps"
apps_config | xargs -l bash -c 'download_app $@' -

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
