#!/bin/bash

# This is to force the backup to run when not running on the crontab

echo "db"
salt "db.webhostonbarter.com" cmd.run "/root/scripts/backup/db.sh"

echo ""
echo "dev"
salt "dev.webhostonbarter.com" cmd.run "/root/scripts/backup/dev.sh"

echo ""
echo "support"
salt "support.webhostonbarter.com" cmd.run "/root/scripts/backup/support.sh"

echo ""
echo "webmail"
salt "webmail.webhostonbarter.com" cmd.run "/root/scripts/backup/webmail.sh"

echo ""
echo "web1"
salt "web1.webhostonbarter.com" cmd.run "/root/scripts/backup/web1.sh"

echo ""
echo "Checking backup..."
salt "backup.webhostonbarter.com" cmd.run "/root/scripts/backup/check.sh | mail -s 'Backup Results' jonathan@purpleman.org"
