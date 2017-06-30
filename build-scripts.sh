apps_config | awk '{sub("/system/", "", $4); printf "%1$s/%2$s/%2$s.apk\n", $4, $3}'
