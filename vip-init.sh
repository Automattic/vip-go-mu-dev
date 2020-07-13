#!/bin/bash

set -o errexit   # exit on error
set -o errtrace  # exit on error within function/sub-shell
set -o nounset   # error on undefined vars
set -o pipefail  # error if piped command fails

has_param() {
    local term="$1"
    shift
    for arg; do
        if [[ $arg == "$term" ]]; then
            return 0
        fi
    done
    return 1
}

exists_or_exit() {
  command -v "$1" &> /dev/null || { echo >&2 "$1 must installed but was not found; exiting"; exit 1; }
}

echo_heading() {
	echo
	echo "======================"
	echo $1
	echo "======================"
	echo
}

ROOT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

WP_VERSION=`curl -Ls http://api.wordpress.org/core/version-check/1.7/ | perl -ne '/"version":\s*"([\d\.]+)"/; print $1;'`

# ---

# Check dependencies

exists_or_exit git
exists_or_exit svn
exists_or_exit npm
exists_or_exit composer
exists_or_exit docker
exists_or_exit lando

# ---

if has_param '--rebuild' "$@"; then
	echo_heading "lando status"
	echo "Destroying lando environment..."
	lando destroy -y
fi

# ---

echo_heading "mu-plugins"
MUPLUGINS_PATH="$ROOT_PATH/mu-plugins"
if [ ! -d "$MUPLUGINS_PATH" ]; then
	echo "Cloning mu-plugins => $MUPLUGINS_PATH"
	git clone git@github.com:Automattic/vip-go-mu-plugins.git $MUPLUGINS_PATH
else
	echo "mu-plugins already exists"
fi

cd $MUPLUGINS_PATH

echo "git submodules"
git submodule update --init --recursive --jobs 8

echo "npm + composer install"
npm install
composer install

# ---

echo_heading "WordPress"

WP_PATH="$ROOT_PATH/wp"
cd $ROOT_PATH
if [ ! -d "$WP_PATH" ]; then
	echo "Cloning WordPress $WP_VERSION => $WP_PATH"
	git clone --branch $WP_VERSION --depth 1 git@github.com:WordPress/WordPress.git $WP_PATH
else
	echo "WordPress already exists; skipping"
fi

echo_heading "VIP Skeleton / wp-content"

SKELETON_PATH="$ROOT_PATH/wp-content"
cd $ROOT_PATH
if [ ! -d "$SKELETON_PATH" ]; then
	echo "Adding Skeleton => $WP_PATH"
	svn export https://github.com/Automattic/vip-go-skeleton/trunk $SKELETON_PATH
else
	echo "Skeleton already exists; skipping"
fi

# ---

echo_heading "Starting Lando"

cd $ROOT_PATH
lando start
