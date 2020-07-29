#!/bin/bash

syntax() {
  echo "Syntax: lando add-site --slug=<slug> --title=\"<title>\""
  exit 1
}

# Parse title and slug arguments
arguments=`getopt -o '' -l slug:,title: -- "$@"`
eval set -- "$arguments"
while true; do
    case "$1" in
    --slug) slug=$2; shift 2;;
    --title) title=$2; shift 2;;
    --) shift; break;;
    esac
done
[ -z "$slug" ] && echo "ERROR: Missing or empty slug argument" && syntax
[ -z "$title" ] && echo "ERROR: Missing or empty title argument" && syntax

site_domain=$slug.vip-go-dev.lndo.site

echo "Checking if this is a multisite installation..."
wp core is-installed --network
[ $? -ne 0 ] && echo "ERROR: Not a multisite, please run 'lando setup-multisite' first" && exit 1

echo "Checking if $site_domain already belongs to another site..."
wp --path=$LANDO_WEBROOT site list --field=domain | grep -q "^$site_domain$"
[ $? -eq 0 ] && echo "ERROR: site with domain $site_domain already exists" && exit 1

echo "Creating the new site..."
site_id=`wp --path=$LANDO_WEBROOT site create --title="$title" --slug="$slug" --porcelain`

# The multisite installation is in subdirectory mode, so we have to change
# the siteurl and home options to the proper domain
echo "Changing 'siteurl' and 'home' options to $site_domain..."
wp --path=$LANDO_WEBROOT --url="http://vip-go-dev.lndo.site/$slug" option update siteurl "http://$site_domain/"
wp --path=$LANDO_WEBROOT --url="http://vip-go-dev.lndo.site/$slug" option update home "http://$site_domain/"

# We also need to change the domain in wp_blogs. This cannot be done from wp-cli
# (only from wp-admin), so we need to run a DB query to change it
echo "Changing the wp_blogs domain to $site_domain..."
echo "UPDATE wp_blogs SET domain=\"$site_domain\", path=\"/\" WHERE blog_id=$site_id" |
mysql -u$DB_USER -p$DB_PASS -h$DB_HOST $DB_NAME
[ $? -ne 0 ] && echo "ERROR: couldn't change the domain in the wp_blogs table" && exit 1

echo
echo "======================================================================"
echo "Site '$title' added correctly"
echo
echo "You can access it using these URLs:"
echo "  http://$site_domain/"
echo "  http://$site_domain/wp-admin/"
echo "======================================================================"
