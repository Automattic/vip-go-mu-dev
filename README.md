## VIP Go mu-plugins Dev

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

To run the `wp` CLI from the local shell, just use `lando wp` as normal.
If for any reasons you need to execute the CLI from within the app container, you can shell into the container using `lando ssh`.

### Local development

Local `plugins` and `themes` directories (inside `wp/wp-content` are mounted in their respective places.

## TODO / Possible Ideas / Improvements

- Checkout of VIP Go Skeleton.
- Provision a multisite install as well.
- Support for vip-sunrise.
- HTTP Concat.
- Files Service + Photon + Stream Wrapper support.
- Enable debug tools by default.
