#!/bin/bash

JP_VERSION=8.9

docker build -t wpvipdev/jetpack:$JP_VERSION --build-arg JP_VERSION=$JP_VERSION .
