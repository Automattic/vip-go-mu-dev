#!/bin/bash

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
git submodule update --init --recursive

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

# ---

echo_heading "JMeter" 

JMETER_TEST_FILES_DIR=$ROOT_PATH/jmeter-test-files
if [ ! -d "$JMETER_TEST_FILES_DIR" ]; then
	echo "Adding JMeter test files directory"
	mkdir $ROOT_PATH/jmeter-test-files
else
	echo "JMeter test files directory already exists; skipping"
fi

# ---

echo_heading "Starting Lando"

cd $ROOT_PATH
lando start
