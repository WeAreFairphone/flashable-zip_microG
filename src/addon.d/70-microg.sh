#!/sbin/sh
#
# /system/addon.d/70-microg.sh
# During a system upgrade, this script backs up microG apps,
# /system is formatted and reinstalled, then the files are restored.
#

. /tmp/backuptool.functions

list_files() {
cat <<EOF
%PLACEHOLDER%
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Stub
  ;;
esac
