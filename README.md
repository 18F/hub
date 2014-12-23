## 18F Hub

The Hub is a Jekyll-based website that helps 18F organize its internal information and explore the connections between team members, projects, and skill sets. It takes less than a minute to set up a hands-on demo, which we hope will inspire other teams to develop their own Hubs, publish snippets, and organize working groups.

The Hub serves as the go-to place for all team-internal information, whether that information is integrated into the Hub directly or provided as links to Google Drive documents, Google Sites, GitHub READMEs and microsites, Slack conversations, etc.

* Main internal Hub: https://hub.18f.us/
* Public Hub staging area: https://hub.18f.us/hub/ 
* Main Git repository: https://github.com/18F/hub

The primary maintainer (for now) is @mbland. The goal is to eventually hand ownership over to the Documentation Working Group as a whole.

### Generating the site/hosting locally

You will need Ruby ( > version 2.0 is a good idea). You may also consider using a Ruby version manager such as [rbenv](https://github.com/sstephenson/rbenv) to help ensure that Ruby version upgrades don't mean all your gems will need to be rebuilt.

To run your own local instance within a minute or two:

```
$ git clone git@github.com:18F/hub.git
$ cd hub
$ gem install bundler
$ bundle
$ bundle exec jekyll serve
```

#### Instructions for 18F team members

18F team members will also want to initialize the [18F/data-private](https://github.com/18F/data-private) and [18F/hub-pages-private](https://github.com/18F/hub-pages-private) submodule after cloning:

```
# Initialize the _data/private and pages/private submodules
$ git submodule init
$ git submodule update --remote
```

By default, `bundle exec jekyll serve` will build the site in "private mode", whereby information from [_data/private](_data/private) is incorporated if it is available. Not all data in `_data/private` is actually private, but data that should not be shared outside the team is marked by nesting it within `private:` attributes. To build in "public mode" so that information marked as private doesn't appear in the generated site:

```
$ bundle exec jekyll serve --config _config.yml,_config_public.yml
```

### Documentation

In addition to this README, there is also:
* [Deployment README](deploy/README.md) - DevOps details: publishing the generated site; AWS; Nginx; SSL; Google Auth Proxy
* [Plugins README](_plugins/README.md) - Development details: data import and joining; canonicalization; cross-referencing; page generation
* [Data README](_data/README.md) - Details regarding the organization and processing of data.

### Contributing

Just fork [18F/hub](https://github.com/18F/hub) and start sending pull requests! Feel free to ping @mbland with any questions you may have, especially if the current documentation should've addressed your needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
