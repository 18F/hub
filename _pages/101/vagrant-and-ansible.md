---
title: Hub 101 - Advanced Local Dev Environment Using Vagrant and Ansible
---
# {{ page.title }}

If you have [Vagrant](https://www.vagrantup.com/) and
[Ansible](http://www.ansible.com/home) installed, you can launch a local
development server running [Nginx](http://nginx.org/) by running `vagrant up`.
The server will be accessible at `localhost:8080` for the internal version,
and `localhost:8080/hub` for the public version.

During development, running `./go build` will generate both the internal and
public versions of the Hub, and both versions will be served by the local
Nginx instance immediately.

For the internal version of the site, the dev server will default to setting
the Nginx `$authenticated_user` variable (used by
[_layouts/bare.html](https://github.com/18F/hub/tree/master/_layouts/bare.html))
to the `authenticated_user` value in
[deploy/ansible/playbook.yml](https://github.com/18F/hub/blob/master/deploy/ansible/playbook.yml). You can also
change this for a single page by adding `?user=[AUTHENTICATED_USER]` to the
URL.
