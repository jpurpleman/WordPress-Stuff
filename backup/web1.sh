#!/bin/bash

# This backups the web sites in /var/www/html and extra folders

array=(
        "/etc"
        "/home"
        "/root"
)

for i in $( find /var/www/html -maxdepth 1 -type d | grep -v '/var/www/html$' )
do
    array=("${array[@]}" $i)
done

for i in "${array[@]}"
do
    filename="/home/backup/web1.webhostonbarter.com/""${i##*/}"".tgz"
    tar zcfP - $i | ssh -i /home/backup/.ssh/id_rsa backup@backup.webhostonbarter.com "cat > $filename"
done
