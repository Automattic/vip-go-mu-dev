#!/bin/sh

rsync -a --delete --delete-delay /wp/ /shared/ #\
#  --exclude config \
#  --exclude wp-content/mu-plugins \
#  --exclude wp-content/client-mu-plugins \
#  --exclude wp-content/images \
#  --exclude wp-content/languages \
#  --exclude wp-content/plugins \
#  --exclude wp-content/private \
#  --exclude wp-content/themes \
#  --exclude wp-content/vip-config

exec sleep infinity
