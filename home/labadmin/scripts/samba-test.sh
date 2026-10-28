#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root or with sudo." >&2
   exit 1
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║    SAMBA FILE SERVER + QUOTA INTEGRATION TEST REPORT       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

echo "1. DISK STATUS"
echo "   $(df -h /srv/samba | grep -v Filesystem)"
echo ""

echo "2. QUOTA STATUS"
quotaon -p /srv/samba 2>&1 | sed 's/^/   /'
echo ""

echo "3. USER QUOTAS"
repquota -s /srv/samba | tail -n +6 | sed 's/^/   /'
echo ""

echo "4. SAMBA SERVICES"
systemctl is-active smbd nmbd | sed 's/^/   smbd\/nmbd: /'
echo ""

echo "5. ACTIVE SHARES"
smbclient -L localhost -N 2>/dev/null | grep "Disk" | sed 's/^/   /'
echo ""

echo "6. SAMBA USERS"
pdbedit -L | sed 's/^/   /'
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  TEST SUMMARY                                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
ERRORS=0

# Check quota is on
quotaon -p /srv/samba 2>&1 | grep -q "is on" && echo "✓ Quota enforcement: ACTIVE" || { echo "✗ Quota: FAILED"; ERRORS=$((ERRORS+1)); }

# Check Samba running
systemctl is-active smbd | grep -q "active" && echo "✓ Samba service: RUNNING" || { echo "✗ Samba: FAILED"; ERRORS=$((ERRORS+1)); }

# Check users exist
pdbedit -L | grep -q "john" && echo "✓ Samba users: CONFIGURED" || { echo "✗ Users: FAILED"; ERRORS=$((ERRORS+1)); }

echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "ALL TESTS PASSED!"
else
    echo "$ERRORS test(s) failed. Please review the configuration."
fi
