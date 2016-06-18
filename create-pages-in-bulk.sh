#!/bin/bash

# First admin user for post authorship
userID=1

pages=( 'Home' 'About' 'Contact Us' )

for page in "${pages[@]}"; do
    wp post create --post_type=page --post_title="$page" --post_status=publish --post_author=$userID --porcelain --quiet 

    echo "wp post create $page"
done

wp menu create "Menu"

export IFS=" "

for pageID in $( wp post list --order="ASC" --orderby="ID" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids ); do
    wp menu item add-post menu $pageID
done

wp menu location assign menu primary
