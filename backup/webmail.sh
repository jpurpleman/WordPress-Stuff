#!/bin/bash

# This backups the web sites in /var/www/, email and other folders

array=(
        "/etc"
        "/home"
        "/var/vmail"
        "/var/www/"
        "/root"
)

for i in "${array[@]}"
do
    filename="/home/backup/webmail.webhostonbarter.com/""${i##*/}"".tgz"
    tar zcfP - $i | ssh -i /home/backup/.ssh/id_rsa backup@backup.webhostonbarter.com "cat > $filename"
done
