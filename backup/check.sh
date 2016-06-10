#!/bin/bash

# This is run to verify the backups are done which gets emailed to me

array=(
    "/home/backup/db.webhostonbarter.com"
    "/home/backup/dev.webhostonbarter.com"
    "/home/backup/support.webhostonbarter.com"
    "/home/backup/web1.webhostonbarter.com"
    "/home/backup/web2.webhostonbarter.com"
    "/home/backup/webmail.webhostonbarter.com"
)

df -h | grep -v 'tmpfs'

echo ""
echo ""
echo ""

for i in "${array[@]}"
do
    ls $i -lAhrS | awk '{print $5  "     " $6 " " $7 " " $8 "     " $9}' | grep -v '\.$'
    du -h $i
    echo ""
    echo ""
    echo ""
done
