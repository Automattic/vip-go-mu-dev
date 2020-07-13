#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset

# Config vars
#
vipswitchpath=/tmp/vip-switch
wpcontentpath=/app/wp-content
vipconfigpath=/tmp/vip-switch/vip-config/vip-config.php
branch=""

# If no arguments are supplied
#
if [ $# -eq 0 ]; then
	read -p "Which site repo do you want to switch to?(e.g: git@github.com:wpcomvip/fake-site.git)? " gitpath
	read -p "Which branch do you want to use?(defaults to master)" branch
else
	PARAMS=""
	while (( "$#" )); do
		case "$1" in
			-b|--branch)
				if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
					branch=$2
					shift 2
				else
					echo "Error: Argument for $1 is missing" >&2
					exit 1
				fi
				;;
			-*|--*=) # unsupported flags
				echo "Error: Unsupported flag $1" >&2
				exit 1
				;;
			*) # preserve positional arguments
				PARAMS="$PARAMS $1"
				shift
				;;
		esac
	done	

	gitpath=$PARAMS
fi

# Default to master branch
#
if [ -z $branch ]; then
	branch=master
fi

# Trim whitespace
#
gitpath=$( echo $gitpath | xargs )
branch=$( echo $branch | xargs )

echo "Cloning repository..."
git clone --single-branch --branch $branch --recurse-submodules -j8 $gitpath $vipswitchpath

# Remove possibly conflicting constants
#
sed -i.bak -E -e '/USE_VIP_ELASTICSEARCH|VIP_ENABLE_ELASTICSEARCH_QUERY_INTEGRATION|DISALLOW_FILE_EDIT|DISALLOW_FILE_MODS|AUTOMATIC_UPDATER_DISABLED|WP_MAX_MEMORY_LIMIT|VIP_ELASTICSEARCH_ENDPOINTS|VIP_ELASTICSEARCH_USERNAME|VIP_ELASTICSEARCH_PASSWORD|WPCOM_VIP_LOAD_CRON_CONTROL_LOCALLY|WP_CRON_CONTROL_SECRET|WP_DEBUG|WP_DEBUG_LOG/d' $vipconfigpath

echo "Clearing previous files..."
rm -rf $wpcontentpath/client-mu-plugins/*
rm -rf $wpcontentpath/config/*
rm -rf $wpcontentpath/image/*
rm -rf $wpcontentpath/languages/*
rm -rf $wpcontentpath/plugins/*
rm -rf $wpcontentpath/private/*
rm -rf $wpcontentpath/themes/*
rm -rf $wpcontentpath/vip-config/*

echo "Copying into wp-content..."
cp -rf $vipswitchpath/* $wpcontentpath

echo "Deleting clone..."
rm -rf $vipswitchpath

# Get a theme
#
theme=$( wp theme list --field=name | tail -n 1 )

if [ -z $theme ]; then
	echo "Please select a theme via a wp theme activate <theme-name> command if one is not selected:"
	wp theme list
else
	echo "Selecting theme $theme. Feel free to change it!"
	wp theme activate $theme
fi
