## VIP Go mu-plugins Dev

> ==============================
>
> THIS REPO IS BEING DEPRECATED.
>
> Please go to https://github.com/Automattic/vip-container-images
>
> ==============================

A development environment for [mu-plugins on VIP Go](https://github.com/Automattic/vip-go-mu-plugins/).

## Install

1. Clone repo.
1. Install SVN: `brew install svn` (or use package manager of your choice).
1. Install [Lando](https://docs.lando.dev/basics/installation.html).
1. Install node+npm.
1. Install Composer.
1. `./vip-init.sh`.

The environment can then be accessed at http://vip-go-dev.lndo.site (username/password is `vipgo`/`password`).

## Tooling and debug

### WP CLI
To run the `wp` CLI from the local shell, just use `lando wp` as normal.
If for any reasons you need to execute the CLI from within the app container, you can shell into the container using `lando ssh`.

### StatsD
StatsD is also reporting to the console as lando runs. To view the output, `lando logs` will show you all output logs including statsd. `lando logs -f` allows you to follow the logs and keep a persistent steam of log data outputting to your console.

### Local development

You can run `lando vip-switch git:<repo url> [optional -b, --branch <branch-name> ]` to switch to the relevant VIP code repository.

Local `plugins` and `themes` directories (inside `wp/wp-content` are mounted in their respective places.

### Multisite

You can enable multisite by running `lando setup-multisite`

You can add multisites after that by running `lando add-site --slug=<slug> --title="<title>"`

### Add test data

You can add posts, users, etc... by running `lando add-fake-data`

You can delete this data by running `lando delete-fake-data`

This is done via wp-fixtures and the details of the defaults are available in [test_fixtures.yml](https://github.com/Automattic/vip-go-mu-dev/blob/master/configs/fixtures/test_fixtures.yml).

## TODO / Possible Ideas / Improvements

- ~~Ability to use a multisite install as well.~~(Added)
- Ability to override baseline config to tweak settings like PHP and WordPress versions.
- Support for vip-sunrise.
- Support for HTTP Concat.
- Mock Files Service + Photon + Stream Wrapper support.
- Support for developing and testing Cron Control runner.
- Support for vip-e2e.
