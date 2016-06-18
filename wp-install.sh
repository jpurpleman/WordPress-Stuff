#!/bin/bash

# Author: Jonathan Perlman < jperlman@dawsoncollege.qc.ca >

function display_help {
  echo "WordPress automatic installer"
  echo ""
  echo "Usage :"
  echo "   wp-install.sh [action]"
  echo "   wp-install.sh [action] [start] [end]"
  echo ""
  echo "Actions :"
  echo "-h --help       Display this help"
  echo "-i --install    Install wordpress"
  echo "-u --uninstall  Uninstall wordpress"
  echo ""
  echo "start           The starting number (optional)"
  echo "end             The ending number (optional)"
  echo ""
}

# This is where all your new sites will reside
BASEPATH="/var/www/html"

# Super user password for mysql
mysqlrootpassword=""


# We need at least one argument
if [ $# -lt 1 ]; then
  display_help
  exit 1
fi

# Check what action we need to perform
case "$1" in
  '-i' | '--install')
    action='install'
    ;;
  '-u' | '--uninstall' )
    action='uninstall'
    ;;
  '-h' | '--help' )
    display_help
    exit
    ;;
  *)
    display_help
    exit 1
    ;;
esac

####################################################################################

# If the user only input in action argument
if [ ! -n "$2" ]; then

  # Ask user what starting site number desired
  start=$(whiptail --inputbox "What number do you want to start from?" 8 58 --title "WordPress Installer" 3>&1 1>&2 2>&3)
  if [ ! -n "$start" ]; then
    echo "User cancelled"
    exit 1
  fi
else
  # Else we have the number from the command line
  start=$2
fi


# If the user only input in action argument and the starting site number
if [ ! -n "$3" ]; then

  # Ask user the ending number
  end=$(whiptail --inputbox "What number do you want to end to?" 8 58 --title "WordPress Installer" 3>&1 1>&2 2>&3)
  if [ ! -n "$end" ]; then
    echo "User cancelled"
    exit 1
  fi
else
  # Else we have the number from the command line
  end=$3
fi

# Sanity check are we going forwards in numbers?
if [ "$start" -gt "$end" ]; then
        whiptail --title "WordPress Installer" --msgbox "I can't count backward, please set an ending number greater than the starting one" 8 70
  exit 1
fi

####################################################################################

# Confirm what the user wants is correct
whiptail --yesno "Are you sure you want to $action wordpress in folders $start to $end ?" 10 70 --title "WordPress Installer"
exitstatus=$?

if [ $exitstatus != 0 ]; then
    echo "User cancelled." 
fi

####################################################################################

range=$((end-start+1))
cnt=0

# If we're going to remove sites
if [ "$action" == "uninstall" ]; then
{
# Loop through the sequence number and ...
for i in $(seq $start $end)
  do

    # Do mysql stuff to drop the db, revoke all and remove the user
    mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "DROP DATABASE IF EXISTS wp_$i;"
    mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "REVOKE ALL ON wp_$i.* FROM wp_$i@localhost;"
    mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "DROP USER wp_$i@localhost;"

    # Create the specific install path for site
    INSTALL_PATH="$BASEPATH/wp$i"

    # If the site exists
    if [[ -d "$INSTALL_PATH" ]]; then

        # Destroy the file system folder of the site
        rm -dfr $INSTALL_PATH
    fi

    # Calc percentage done and send back to whiptail
    percent=$(( 100*(++cnt)/range ))
    echo $percent

  done
  }|whiptail --title "WordPress Uninstall folders $start to $end" --gauge "Please wait" 5 50 0
  exit
else
  # Loop throuh all proposed sites and make sure we don't overwrite any folder
  for i in $(seq $start $end)
  do
    # Create the specific install path for site
    INSTALL_PATH="$BASEPATH/wp$i"

    # If the site exists
    if [[ -d "$INSTALL_PATH" ]]; then

      # Alert and stop now!
      whiptail --title "WordPress Installer" --msgbox "Directory $INSTALL_PATH already exist. Aborting" 8 70
      exit 1
    fi
  done

  rm -rf /root/wp-pass.log
  PASS="/root/wp-pass.log"

  echo "Dawson College WordPress Site Information" >> $PASS
  echo "-----------------------------------------" >> $PASS
  echo "" >> $PASS
  echo "" >> $PASS
  echo "" >> $PASS

  rm -rf /root/wp-install.log

  LOG="/root/wp-install.log"
  {
  for i in $(seq $start $end)
  do
        # Foreach new site create a random secure password
        wp_pass=`head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`

        # Mysql stuff, drop db if exists, create database, grant privileges and flush privileges
        mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "DROP DATABASE IF EXISTS wp_$i;"
        mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "CREATE DATABASE IF NOT EXISTS wp_$i;"
        mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "GRANT ALL ON wp_$i.* TO wp_$i@localhost IDENTIFIED BY '$wp_pass';"
        mysql -h "localhost" "--user=root" "--password=$mysqlrootpassword" -e "FLUSH PRIVILEGES;"

        ####################################################################################

        # Set the install path variable
        INSTALL_PATH="$BASEPATH/wp$i"
        if [[ -d "$INSTALL_PATH" ]]; then

            # Delete the install path if it exist.  It shouldn't but you never know
            rm -dfr $INSTALL_PATH
        fi

        # Create the directory of the install path
        mkdir $INSTALL_PATH

        # Go into the install path
        cd $INSTALL_PATH

        ####################################################################################

        # download the WordPress core files
        wp core download --quiet

        # create the wp-config file with our standard setup
        wp core config --dbname=wp_$i --dbuser=wp_$i --dbpass=$wp_pass  --quiet

        # parse the current directory name
        currentdirectory=${PWD##*/}

        # generate random 8 character password
        user_password=`head -c 500 /dev/urandom | tr -dc '0-9' | fold -w 8 | head -n 1`

        # create database, and install WordPress
        wp core install \
                --url="http://wpcourse.dawsoncollege.qc.ca/$currentdirectory" \
                --title="Student $i WordPress Website" \
                --admin_user="student$i" \
                --admin_password="Daw$user_password" \
                --admin_email="student$i@dawsoncollege.qc.ca" --quiet

        ####################################################################################

        # Dump out information to a text file for the teacher
        echo "student$i       Daw$user_password    _________________________________" >> $PASS
        echo "" >> $PASS
        echo "" >> $PASS
        echo "" >> $PASS
        echo "" >> $PASS


        # Dump out information for the specific student
        echo "Dawson College WordPress Site Information" >> $LOG
        echo "-----------------------------------------" >> $LOG
        echo "" >> $LOG

        echo "You have been given a WordPress site." >> $LOG
        echo "" >> $LOG
        echo "To access the public website please use the following:" >> $LOG
        echo "" >> $LOG
        echo "http://wpcourse.dawsoncollege.qc.ca/$currentdirectory" >> $LOG
        echo "" >> $LOG
        echo "To access the admin login of the website please use the following:" >> $LOG
        echo "" >> $LOG
        echo "https://wpcourse.dawsoncollege.qc.ca/$currentdirectory/wp-admin" >> $LOG
        echo "" >> $LOG
        echo "Please use this username and password to login." >> $LOG
        echo "" >> $LOG
        echo "" >> $LOG
        echo "student$i" >> $LOG
        echo "Daw$user_password" >> $LOG
        echo "" >> $LOG
        echo "" >> $LOG
        echo "This account is not tied to any other services at Dawson College." >> $LOG
        echo "" >> $LOG
        echo "When working outside the college, you will be required to enter your" >> $LOG
        echo "username and password before getting to the public side of your site." >> $LOG
        echo "This is done to ensure the security of your site." >> $LOG
        echo "" >> $LOG
        echo "The following plugins listed here will cause your site to crash on our" >> $LOG
        echo "server.  DO NOT install them.  When using web hosting outside Dawson " >> $LOG
        echo "College, you may install them but be aware that they make changes to a" >> $LOG
        echo "file called .htaccess which might have unintended side effects." >> $LOG
        echo "Information about .htaccess can be found here:" >> $LOG
        echo "https://codex.wordpress.org/htaccess" >> $LOG
        echo "" >> $LOG
        echo "WP Super Cache" >> $LOG
        echo "WP File Cache" >> $LOG
        echo "WP Rocket" >> $LOG
        echo "W3 Total Cache" >> $LOG
        echo "VersionPress" >> $LOG
        echo "BulletProof Security" >> $LOG
        echo "iThemes Security (formerly Better WP Security)" >> $LOG
        echo "" >> $LOG
        echo "For technical support with your WordPress site, please contact your teacher." >> $LOG

        for line in {1..15}; do echo "" >> $LOG; done

        ####################################################################################

        # discourage search engines
        wp option update blog_public 0 --quiet

        # delete sample page, and create homepage
        wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)  --quiet
        wp post create --post_type=page --post_title=Home --post_status=publish --post_author=1 --quiet

        # set homepage as front page
        wp option update show_on_front 'page' --quiet

        # set pretty urls
        wp rewrite structure '/%postname%/' --hard  --quiet
        wp rewrite flush --hard  --quiet  --quiet

        # delete akismet and hello dolly
        wp plugin delete akismet  --quiet
        wp plugin delete hello --quiet

        # create a navigation bar
        wp menu create "Main Navigation"  --quiet

        # disable file edit in wordpress config
        sed -i "s/table_prefix = 'wp_';/table_prefix = 'wp_';\ndefine( 'DISALLOW_FILE_EDIT', true );/" $INSTALL_PATH/wp-config.php

        ####################################################################################

        # create .htaccess file
        FN="$INSTALL_PATH/.htaccess"

        echo "# BEGIN WordPress" > $FN
        echo "<IfModule mod_rewrite.c>" >> $FN
        echo "RewriteEngine On" >> $FN
        echo "RewriteBase /wp$i/" >> $FN
        echo "RewriteRule ^index\.php$ - [L]" >> $FN
        echo "RewriteCond %{REQUEST_FILENAME} !-f" >> $FN
        echo "RewriteCond %{REQUEST_FILENAME} !-d" >> $FN
        echo "RewriteRule . /wp$i/index.php [L]" >> $FN
        echo "</IfModule>" >> $FN
        echo "# END WordPress" >> $FN
        echo "# BEGIN password protect based on IP" >> $FN
        echo "<IfModule mod_authn_file.c>" >> $FN
        echo "AuthType Basic" >> $FN
        echo 'AuthName "External Access"' >> $FN
        echo "AuthUserFile $INSTALL_PATH/.htpasswd" >> $FN
        echo "Require valid-user" >> $FN
        echo "Order Deny,Allow" >> $FN
        echo "Deny from all" >> $FN
        echo "Allow from 198.168.48.0/255.255.255.0" >> $FN
        echo "Allow from 10.0.0.0/255.0.0.0" >> $FN
        echo "Satisfy Any" >> $FN
        echo "</IfModule>" >> $FN
        echo "# END password protect based on IP" >> $FN

        # create the .htpasswd file
        htpasswd -b -c $INSTALL_PATH/.htpasswd "student$i" Daw$user_password > /dev/null 2>&1

        # change ownership of the folder to apache
        chown -R apache.apache $INSTALL_PATH

        # changing file permissions
        find $INSTALL_PATH -type f -exec chmod 664 {} \;
        find $INSTALL_PATH -type d -exec chmod 775 {} \;

        # Calculate and send percent done to whiptail
        percent=$(( 100*(++cnt)/range ))
        echo $percent
  done
  }|whiptail --title "WordPress Install folders $start to $end" --gauge "Please wait" 5 50 0
fi

####################################################################################

# Convert text file of info for teacher to pdf
enscript -B -f Courier12 --margins=26:18:18:18 -p wp-pass.ps wp-pass.log 
ps2pdf wp-pass.ps wp-pass.pdf

# Deleteing intermediate files
rm -rf wp-pass.log
rm -rf wp-pass.ps

# Send to my home directory
mv wp-pass.pdf /home/jperlman
chown jperlman:jperlman wp-pass.pdf

####################################################################################

# Convert many student one page documents into one pdf
enscript -B -f Courier12 --margins=26:18:18:18 -p wp-install.ps wp-install.log 
ps2pdf wp-install.ps wp-install.pdf

# Deleteing intermediate files
rm wp-install.ps
rm wp-install.log

# Send to my home directory
mv wp-install.pdf /home/jperlman
chown jperlman:jperlman wp-install.pdf

####################################################################################

exit
