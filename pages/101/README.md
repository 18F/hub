---
title: Hub 101
permalink: /101/
---
# {{ page.title }}

This document lays out the basic flow of standing up an local instance of the
18F Hub, understanding how its data model and plugins work, and how to deploy
it in a production environment.

## `rbenv`

[Setting up the Ruby environment with `rbenv`](rbenv/) contains tips for
setting up the `rbenv` Ruby environment manager. `rbenv` isn't a requirement,
but it's highly recommended.

## `./go`

[Using the `./go` Script](go/) explains the primary interface to the Hub
development environment.

## Internal vs. Public Hubs

[Internal vs. Public Hubs](internal-vs-public/) describes the differences
between the "internal" and "public" versions of the Hub.

## `_data/private` and `pages/private`

[Working with Git Submodules](git-submodules/) explains how to initialize the
`_data/private` and `pages/private` submodules, along with tips for working
with them.

## Plugins

[_plugins/README.md](https://github.com/18F/hub/tree/master/_plugins/README.md)
contains high-level info on how Hub data is processed before pages are
rendered. It also describes the plugins that generate cross-linked pages for
individual data entities.

## Deployment

[deploy/README.md](https://github.com/18F/hub/tree/master/deploy/README.md)
contains the grisly details of how the 18F Hubs are currently deployed, using
AWS, `rbenv`, `ssh`, `hookshot.js`, Fabric, Nginx, the Google Auth Proxy, and
GitHub webhooks.

You can also see the deprecated [`deploy/publish.sh`
script](https://github.com/18F/hub/tree/master/deploy/publish.sh) script for
an example of how to deploy the Hub using `rsync`.

## Advanced Development

[Advanced Local Dev Environment Using Vagrant and
Ansible](vagrant-and-ansible/) explains how to develop locally using Vagrant
and Ansible, versus using/switching between `./go serve` and `./go
serve_public`.
