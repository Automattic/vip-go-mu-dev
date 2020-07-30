#!/bin/bash

syntax() {
  echo "Syntax: vip-create.sh -s <slug> [-t \"<title>\"] [-m] [-w <wordpress_version>]"
  echo "                      [-r <client_repo>] [-b <client_branch>] [-u <mu_branch>]"
  echo
  echo "  -s <slug>           Short name to be used for the lando project and the internal domain"
  echo "  -t <title>          Title for the WordPress site (default: \"VIP Go Dev\")"
  echo "  -m                  Enable multisite WordPress install"
  echo "  -w <wp_version>     Use a specific WordPress version (default: last stable version)"
  echo "  -r <client_repo>    Clone a specific client code repository (default: vip-go skeleton)"
  echo "  -b <client_branch>  Use this branch from the client code repository (default: master)"
  echo "  -u <mu_branch>      Use this branch for the mu-plugins repository (default: master)"
}

# Parse arguments
while getopts "hs:t:mw:r:b:u:" opt; do
  case "$opt" in
    h) syntax; exit;;
    s) slug=$OPTARG;;
    t) title=$OPTARG;;
    m) multisite=1;;
    w) wp_version=$OPTARG;;
    r) client_repo=$OPTARG;;
    b) client_branch=$OPTARG;;
    u) mu_branch=$OPTARG;;
  esac
done

[ -z "$slug" ] && echo "ERROR: Missing or empty slug argument" && syntax && exit 1

instance=site-$slug

[ -d "$instance" ] && echo "ERROR: Site already exists. Remove $instance and try again" && exit 1

mkdir $instance
cd $instance

# TODO: could we reuse some of the WordPress clone across multiple instances?
[ -z "$wp_version" ] && wp_version=`curl -Ls http://api.wordpress.org/core/version-check/1.7/ | perl -ne '/"version":\s*"([\d\.]+)"/; print $1;'`
echo "Cloning WordPress $wp_version"
git clone --branch $wp_version --depth 1 git@github.com:WordPress/WordPress.git wp

# TODO: should we reuse mu-plugins+branch clone across multiple instances?
[ -z "$mu_branch" ] && mu_branch="master"
echo "Cloning mu-plugins on branch $mu_branch"
git clone git@github.com:Automattic/vip-go-mu-plugins.git mu-plugins -b $mu_branch
cd mu-plugins
echo "git submodules"
git submodule update --init --recursive --jobs 8
echo "npm + composer install"
npm install
composer install
cd ..

echo "VIP client code"
if [ -n "$client_repo" ]; then
  [ -z "$client_branch" ] && client_branch="master"
  git clone $client_repo wp-content -b $client_branch
  # TODO: change the theme
  # TODO: enable client plugins?
else
  # TODO: reuse vip-go-skeleton across multiple instances
  svn export https://github.com/Automattic/vip-go-skeleton/trunk wp-content
fi

# TODO: support for the provided title (do we want this?)
# TODO: multisite support

echo "Creating .env"
cat ../.env.tpl | sed -e "s/%LANDO_NAME%/$slug/g" > .env
echo "Creating .lando.yml"
cat ../.lando.yml.tpl | sed -e "s/%LANDO_NAME%/$slug/g" > .lando.yml

echo lando start
