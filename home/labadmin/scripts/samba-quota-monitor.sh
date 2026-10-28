#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root or with sudo." >&2
  exit 1
fi

LOGFILE="/var/log/samba-quota-monitor.log"
echo "=== Quota Check: $(date) ===" >> $LOGFILE

repquota -s /srv/samba >> $LOGFILE
echo "" >> $LOGFILE

OVER_QUOTA=$(repquota /srv/samba | grep '++')
if [ ! -z "$OVER_QUOTA" ]; then
    echo "WARNING: Users over quota detected!" >> $LOGFILE
    echo "$OVER_QUOTA" >> $LOGFILE
fi
