#!/bin/bash

# This is to backup the database server.

array=(
        "/etc"
        "/home"
        "/root"
)

for i in "${array[@]}"
do
    filename="/home/backup/db.webhostonbarter.com/""${i##*/}"".tgz"
    tar zcfP - $i | ssh -i /home/backup/.ssh/id_rsa backup@backup.webhostonbarter.com "cat > $filename"
done
