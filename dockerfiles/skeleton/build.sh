#!/bin/bash

CHANGESET=181a17d9aedf7da73730d65ccef3d8dbf172a5c5

docker build -t wpvipdev/skeleton:$CHANGESET --build-arg CHANGESET=$CHANGESET .
