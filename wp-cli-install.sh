#!/bin/bash

# Define the servers by host name or ip address
servers=( 'web1.example.com' 'web2.example.com' )

# Download WP-CLI locally
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Loop throuh the servers
for server in "${servers[@]}"; do

    echo $server

    # Send wp-cli over to the server with a user on the box
    scp ./wp-cli.phar user@$server:

    #Send a command to run on the box - make wp-cli executable
    ssh user@$server  "chmod +x wp-cli.phar"

    #Send a command to run on the box - Move the phar file to a good location and file name
    ssh user@$server  "sudo mv wp-cli.phar /usr/local/bin/wp"

    #Send a command to run on the box - Test wp-cli
    ssh user@$server "/usr/local/bin/wp --info"
done

# delete the file locally
rm ./wp-cli.phar
