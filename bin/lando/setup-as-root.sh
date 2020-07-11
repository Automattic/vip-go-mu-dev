#!/bin/bash

set -e

set -o errexit   # exit on error
set -o errtrace  # exit on error within function/sub-shell
set -o nounset   # error on undefined vars
set -o pipefail  # error if piped command fails

echo_heading() {
	echo
	echo "======================"
	echo $1
	echo "======================"
	echo
}

# Setup Cron Control
echo_heading "Setting up Cron Control"

cp $LANDO_MOUNT/bin/wp/cron-control-runner /usr/local/bin/cron-control-runner
cp $LANDO_MOUNT/mu-plugins/cron-control/runner/init.sh /etc/init.d/cron-control-runner
cp $LANDO_MOUNT/configs/cron-control-defaults /etc/default/cron-control-runner
update-rc.d cron-control-runner defaults
/etc/init.d/cron-control-runner start
/etc/init.d/cron-control-runner status
