#!/bin/bash

# Check if this is already a multisite installation
wp core is-installed --network
[ $? -eq 0 ] && echo "WARNING: Multisite already setup, no need to do anything" && exit 1

echo "Converting installation to multisite..."
wp core multisite-convert --path=$LANDO_WEBROOT --title="VIP Go Dev Network"

echo "=============================================================="
echo "WordPress installation converted to multisite"
echo
echo "You can now add sites with \"lando add-site <slug> <title>\""
echo
echo "If you add a site manually from wp-admin, please use this as"
echo "the site url: http://<slug>.vip-go-dev.lndo.site"
echo "=============================================================="
