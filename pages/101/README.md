## Hub 101

This document lays out the basic flow of standing up an local instance of the
18F Hub, understanding how its data model and plugins work, and how to deploy
it in a production environment.

### Setting up the Ruby environment with `rbenv`

[rbenv.md](rbenv.md) contains tips for setting up the `rbenv` Ruby environment
manager. `rbenv` isn't a requirement, but it's highly recommended.

### Using the `./go` Script

[go.md](go.md) explains how to use the `./go` script, the primary interface to
the Hub development environment.

### Internal vs. Public Hubs

[internal-vs-public.md](internal-vs-public.md) describes the differences
between the "internal" and "public" versions of the Hub.

### Working with Git Submodules

[git-submodules.md](git-submodules.md) explains how to initialize the
`_data/private` and `pages/private` submodules, along with tips for working
with them.

### Plugins

[_plugins/README.md](../_plugins/README.md) contains high-level info on how
Hub data is processed before pages are rendered. It also describes the plugins
that generate cross-linked pages for individual data entities.

### Deployment

[deploy/README.md](../deploy/README.md) contains the grisly details of how the
18F Hubs are currently deployed, using AWS, `rbenv`, `ssh`, `hookshot.js`,
Fabric, Nginx, the Google Auth Proxy, and GitHub webhooks.

You can also see the deprecated [`deploy/publish.sh`
script](../deploy/publish.sh) script for an example of how to deploy the Hub
using `rsync`.

### Advanced Development: Vagrant and Ansible

[vagrant-and-ansible.md](vagrant-and-ansible.md) explains how to develop
locally using Vagrant and Ansible, versus using/switching between `./go serve`
and `./go serve_public`.
