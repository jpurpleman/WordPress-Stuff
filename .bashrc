# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions

alias wordpress-salt='wget https://api.wordpress.org/secret-key/1.1/salt/ -qO-'

alias wordpress-update-all='wp core update && wp core update-db && wp plugin update --all && wp theme update --all'

alias wordpress-remove-default-widgets='wp widget delete search-2 && wp widget delete recent-posts-2 && wp widget delete recent-comments-2 && wp widget delete archives-2 && wp widget delete categories-2 && wp widget delete meta-2'

function git-wp-commit-object() {

    # Get the current directory
    startdir=${PWD##*/}

    if [[ ! -f ../../../wp-config.php ]]; then
        echo "Can't find the wp-config.php file. Are you in a plugin or theme directory?"
        echo ""
        echo "Currently in: $startdir"
        echo ""
        echo "Exiting..."
    else

        # we're in a plugin or theme folder, find out which one, plugin or theme
        cd ..
        wpcontent_folder=${PWD##*/}
        cd $startdir

        # Convert plugins to plugin, themes to theme - removes the last character
        object="${wpcontent_folder%?}"

        # Get details about the wordpress object we want to commit
        title=$(wp ${object} get ${startdir} --field=title)
        version=$(wp ${object} get ${startdir} --field=version)

        git ls-files . --error-unmatch > /dev/null 2>&1;

        if [ $? == 0 ]; then
            action="Updating"
            direction="to"
        else
            action="Adding"
            direction="at"
        fi

        git add .
        git add . -u

        git commit -m "$action $object: $title $direction version $version"
        echo "$action $object: $title $direction version $version"

    fi
}
