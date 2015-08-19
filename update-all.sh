#!/bin/bash

# changing ownership so that we can update all files
chown -R jpurpleman:jpurpleman /var/www/html

root="/var/www/html"

# Changing directory into where all the sites are setup
cd $root

# Loop through all the sites
for site in *;
do

	path="$root/$site"
	
	if [[ -d $path ]]; then

    # Go into the site folder
	cd "$root/$site"

	pwd

    # Update WordPress core
	wp core update --allow-root

    # Update WordPress db after core update
	wp core update-db --allow-root

	echo ""

	fi;
done

# Change ownership back to apache after update so people can use WordPress admin
chown -R apache:apache /var/www/html
