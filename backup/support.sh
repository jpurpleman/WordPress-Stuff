#!/bin/bash

# This backups the support server

array=(
	"/etc"
	"/home"
	"/root"
	"/usr/local/nagios"
	"/var/lib/gitolite3"
	"/var/www/html"
)

for i in "${array[@]}"
do
    filename="/home/backup/support.webhostonbarter.com/""${i##*/}"".tgz"
    tar zcfP - $i | ssh -i /home/backup/.ssh/id_rsa backup@backup.webhostonbarter.com "cat > $filename"
done
