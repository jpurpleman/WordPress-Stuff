# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions

alias wordpress-salt='wget https://api.wordpress.org/secret-key/1.1/salt/ -qO-'

alias wordpress-update-all='wp core update && wp core update-db && wp plugin update --all && wp theme update --all'

alias wordpress-remove-default-widgets='wp widget delete search-2 && wp widget delete recent-posts-2 && wp widget delete recent-comments-2 && wp widget delete archives-2 && wp widget delete categories-2 && wp widget delete meta-2'

alias wordpress-delete-sample-page='wp post delete $( wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids )'

function git-wp-commit-object() {

    # Get the current directory
    startdir=${PWD##*/}

    # Check to see if we're in a plugin or theme folder
    if [[ ! -f ../../../wp-config.php ]]; then
        echo "Can't find the wp-config.php file. Are you in a plugin or theme directory?"
        echo ""
        echo "Currently in: $startdir"
        echo ""
        echo "Exiting..."
    else

        # We're in a plugin or theme folder, find out which one, plugin or theme
        cd ..
        wpcontent_folder=${PWD##*/}
        cd $startdir

        # Convert "plugins" to plugin or "themes" to theme or in other words remove the last character
        object="${wpcontent_folder%?}"

        # Get details about the wordpress object we want to commit
        # Get the title of the plugin or theme we're committing
        title=$(wp ${object} get ${startdir} --field=title)

        # Get the version of the plugin or theme we're committing
        version=$(wp ${object} get ${startdir} --field=version)

        # Check to see if it's in the repo already or not
        git ls-files . --error-unmatch > /dev/null 2>&1;

        # Create parts of the commit message conditionally
        if [ $? == 0 ]; then
            action="Updating"
            direction="to"
        else
            action="Adding"
            direction="at"
        fi

        # Add all files to git that have been added or modified
        git add .

        # Add all files to git that have been deleted or moved
        git add . -u

        # Git commit! with appropriate message
        git commit -m "$action $object: $title $direction version $version"

        # Print that message
        echo "$action $object: $title $direction version $version"

    fi
}
