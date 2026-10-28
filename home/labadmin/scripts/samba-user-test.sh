#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root or with sudo." >&2
  exit 1
fi

for user in john alice bob admin; do
    echo "=== User: $user ==="
    sudo quota -u $user -s
done
