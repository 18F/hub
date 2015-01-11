## 18F Hub

[![Build Status](https://travis-ci.org/18F/hub.svg?branch=master)](https://travis-ci.org/18F/hub)
[![Code Climate](https://codeclimate.com/github/18F/hub/badges/gpa.svg)](https://codeclimate.com/github/18F/hub)
[![Test Coverage](https://codeclimate.com/github/18F/hub/badges/coverage.svg)](https://codeclimate.com/github/18F/hub)

[The 18F Hub](https://18f.gsa.gov/hub) is a [Jekyll](http://jekyllrb.com/)-based documentation platform that aims to help [18F](https://github.com/18F) and other development teams organize and easily share their information, and to enable easy exploration of the connections between team members, projects, and skill sets. It aims to serve as the go-to place for all of a team's working information, whether that information is integrated into the Hub directly or provided as links to other sources. It also serves as a lightweight tool that other teams can experiment with and deploy with a minimum of setup.

See the [18F blog post announcing the Hub](https://18f.gsa.gov/2014/12/23/hub/) for more details about the vision behind the Hub and the goals it aims to achieve.

The main Git repository is https://github.com/18F/hub and the primary maintainer (for now) is [@mbland](https://github.com/mbland). The goal is to eventually hand ownership over to the [Documentation Working Group](https://18f.gsa.gov/hub/wg/documentation), or to the 18F team as a whole.

### Generating the site/hosting locally

It takes less than a minute to set up a hands-on demo, which we hope will inspire other teams to develop their own Hubs, publish [snippets](https://18f.gsa.gov/2014/12/17/snippets/), and organize working groups/guilds/grouplets.

You will need [Ruby](https://www.ruby-lang.org) ( > version 2.0 is a good idea). You may also consider using a Ruby version manager such as [rbenv](https://github.com/sstephenson/rbenv) to help ensure that Ruby version upgrades don't mean all your [gems](https://rubygems.org/) will need to be rebuilt.

To run your own local instance:

```
$ git clone git@github.com:18F/hub.git
$ cd hub
$ ./go init
$ ./go serve
```

This will check that your Ruby version is supported, install the [Bundler gem](http://bundler.io/) if it is not yet installed, install all the gems needed by the Hub, and launch a running instance on `http://localhost:4000`.

After going through these steps, run `./go` to see a list of available commands. The `test`, `serve`, and `serve_public` commands are the most common for routine development.

### Instructions for 18F team members

The internal 18F Hub is hosted at https://hub.18f.us/ and the public Hub staging area is hosted at https://hub.18f.us/hub.

18F team members will want to initialize the [18F/data-private](https://github.com/18F/data-private) and [18F/hub-pages-private](https://github.com/18F/hub-pages-private) submodules after cloning:

```
# Initialize the _data/private and pages/private submodules
$ git submodule init
$ git submodule update --remote
```

By default, `./go serve` will build the site with data from [_data/private](_data/private) if it is available. Not all data in `_data/private` is actually private, but data that should not be shared outside the team is marked by nesting it within `private:` attributes. To build in "public mode" so that information marked as private doesn't appear in the generated site:

```
$ ./go serve_public
```

See the [Data README](_data/README.md) for instructions on how to import data into [_data/public](_data/public) for deployment to the Public Hub.

#### Advanced Local Dev Environment

If you have [Vagrant](https://www.vagrantup.com/) and [Ansible](http://www.ansible.com/home) installed, you can launch a local development server running [Nginx](http://nginx.org/) by running `vagrant up`. The server will be accessible at `localhost:8080` for the internal version, and `localhost:8080/hub` for the public version.

During development, running `./go build` will generate both the internal and public versions of the Hub, and both versions will be served by the local Nginx instance immediately.

For the internal version of the site, the dev server will default to setting the Nginx `$authenticated_user` variable (used by [_layouts/bare.html](_layouts/bare.html)) to the `authenticated_user` value in [deploy/ansible/playbook.yml](deploy/ansible/playbook.yml). You can also change this for a single page by adding `?user=[AUTHENTICATED_USER]` to the URL.

### Documentation

In addition to this README, there is also:
* [Deployment README](deploy/README.md) - DevOps details: publishing the generated site; AWS; Nginx; SSL; Google Auth Proxy
* [Plugins README](_plugins/README.md) - Development details: data import and joining; canonicalization; cross-referencing; page generation
* [Data README](_data/README.md) - Details regarding the organization and processing of data.

### Contributing

1. Fork the repo ( https://github.com/18F/hub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Feel free to ping [@mbland](https://github.com/mbland) with any questions you may have, especially if the current documentation should've addressed your needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
