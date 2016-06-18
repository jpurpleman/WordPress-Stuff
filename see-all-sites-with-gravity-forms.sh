#!/bin/bash

# Loop through all the sites and show the blog number and
# and then the count of how many gravity forms are on the site

for blog_id in $(wp site list --field=blog_id --url=http://www.site.com | sort -u )
do
    echo $blog_id
    wp db query "select count(id) from wp_${blog_id}_rg_form" 
done
