#!/bin/bash

# Check if this is already a multisite installation
wp core is-installed --network
[ $? -eq 0 ] && echo "WARNING: Multisite already setup, no need to do anything" && exit 1

echo "Converting installation to multisite..."
wp core multisite-convert --path=$LANDO_WEBROOT --title="VIP Go Dev Network" --subdomains

echo "=========================================================================="
echo "WordPress installation converted to multisite"
echo
echo "You can now add sites with:"
echo "  lando add-site --slug=<slug> --title=\"<title>\""
echo
echo "You can also add sites manually from wp-admin. In both cases, sites"
echo "will follow this url schema: http://<slug>.vip-go-dev.lndo.site/"
echo "=========================================================================="
