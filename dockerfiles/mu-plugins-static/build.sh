#!/bin/bash

CHANGESET=aabaf807ee150e7c29679410c754c037ed734023

docker build -t wpvipdev/mu-plugins:$CHANGESET --build-arg CHANGESET=$CHANGESET .
