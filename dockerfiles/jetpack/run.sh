#!/bin/sh

rsync -a --delete --delete-delay /jetpack/ /shared/

exec sleep infinity
