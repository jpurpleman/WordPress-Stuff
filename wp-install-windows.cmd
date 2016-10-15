:: Written for EQ WordPress Advanced: Theme Development
:: By Jonathan Perlman
:: jperlman@dawsoncollege.qc.ca
:: Feb. 2, 2016

:: Variables for modification

:: Used in the folder name of the WordPress install
SET SHORT_PROJECT_NAME="wordpress"

:: Use of " has to to be = \" 
SET SITE_TITLE="EQ WordPress Advanced: Theme Development"

:: Information for the "5 - minute install"
:: Admin login for designer / developer in the WordPress Dashboard
SET WPUSER="developer"
SET WPPASSWORD="wordpress"
SET WPEMAIL="developer@email.com"

:: Information for the wp-config.php.  Modify per project
SET DBNAME="wp_project"
SET DBUSER="wp_project"
SET DBPASS="wp_project"

:: Web root of local web server
SET ROOT=C:\wamp\www\

:: Modification after this point is at your own risk!

::-------------------------------------------------------------------------------

:: MySql database stuff
mysql -u root -e "DROP DATABASE IF EXISTS %DBNAME%;"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS %DBNAME%;"
mysql -u root -e "GRANT ALL ON %DBNAME%.* TO %DBUSER%@localhost IDENTIFIED BY '%DBPASS%';"
mysql -u root -e "FLUSH PRIVILEGES;"

:: Changing to directory of installation
cd %ROOT%

:: Delete the install folder
echo Y | del /Q /S %SHORT_PROJECT_NAME%

:: Create the install folder
mkdir %SHORT_PROJECT_NAME%

:: Change directory into the install folder
cd %SHORT_PROJECT_NAME%

:: Downloading the latest version of WordPress Core
call wp core download --version="4.4.2"

:: Creating wp-config.php
call wp core config --dbname="%DBNAME%" --dbuser="%DBUSER%" --dbpass="%DBPASS%"

:: Doing "5 - Minute install"
call wp core install --url="http://localhost/%SHORT_PROJECT_NAME%" --title=%SITE_TITLE% --admin_user="%WPUSER%" --admin_password="%WPPASSWORD%" --admin_email="%WPEMAIL%"

:: Creating child theme for students to use
call wp scaffold child-theme twentysixteen-child --parent_theme="twentysixteen" --theme_name="EQ WP Advanced Twenty Sixteen Theme" --author="Jonathan Perlman" --author_uri="http://www.dawsoncollege.qc.ca" --theme_uri="http://www.dawsoncollege.qc.ca" --activate

:: Updating plugins
call wp plugin update --all 

:: Updating themes
call wp theme update --all 

:: set pretty urls
:: we set pretty urls here to give it some time to complete before flushing the permalinks later
:: unfortunatly call does not work on this command so we have to open and run in a seperate cmd window
start cmd /c wp rewrite structure /%%year%%/%%monthnum%%/%%day%%/%%postname%%/ --hard

:: unfortunatly call does not work on this command so we have to open and run in a seperate cmd window
start cmd /c wp rewrite flush --hard

:: Launch the default browser and bring up the home page of the new site
start http://localhost/%SHORT_PROJECT_NAME%

:: Hold the screen open and not close when done
:: In the event of errors, remove the :: on the next two lines
:: echo Press ENTER to execute the command
:: pause > nul