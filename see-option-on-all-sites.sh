#!/bin/bash

# Foreach site show the site option blogname

for url in $( wp site list --field=url --url=http://site.com | sort -u )
do
    echo $url
    wp option get blogname
done

