#!/bin/bash

WP_VERSION=5.5.1

docker build -t wpvipdev/wordpress:$WP_VERSION --build-arg WP_VERSION=$WP_VERSION .
