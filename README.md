[![Stories in Ready](https://badge.waffle.io/18F/hub.png?label=ready&title=Ready)](https://waffle.io/18F/hub)
[![Coverage Status](https://coveralls.io/repos/18F/hub/badge.svg?branch=coveralls)](https://coveralls.io/r/18F/hub?branch=coveralls)

## 18F Hub

[![Build Status](https://travis-ci.org/18F/hub.svg?branch=master)](https://travis-ci.org/18F/hub)
[![Code Climate](https://codeclimate.com/github/18F/hub/badges/gpa.svg)](https://codeclimate.com/github/18F/hub)
[![Test Coverage](https://codeclimate.com/github/18F/hub/badges/coverage.svg)](https://codeclimate.com/github/18F/hub)

[The 18F Hub](https://18f.gsa.gov/hub) is a
[Jekyll](http://jekyllrb.com/)-based documentation platform that aims to help
[18F](https://github.com/18F) and other development teams organize and easily
share their information, and to enable easy exploration of the connections
between team members, projects, and skill sets. It aims to serve as the go-to
place for all of a team's working information, whether that information is
integrated into the Hub directly or provided as links to other sources. It
also serves as a lightweight tool that other teams can experiment with and
deploy with a minimum of setup.

The internal 18F Hub is hosted at https://hub.18f.us/ and the public Hub
staging area is hosted at https://hub.18f.us/hub.

See the [18F blog post announcing the
Hub](https://18f.gsa.gov/2014/12/23/hub/) for more details about the vision
behind the Hub and the goals it aims to achieve.

The main Git repository is https://github.com/18F/hub and the primary
maintainer (for now) is [@mbland](https://github.com/mbland). The goal is to
eventually hand ownership over to the [Documentation Working
Group](https://18f.gsa.gov/hub/wg/documentation), or to the 18F team as a
whole.

### Generating the site/hosting locally

It takes less than a minute to set up a hands-on demo, which we hope will
inspire other teams to develop their own Hubs, publish
[snippets](https://18f.gsa.gov/2014/12/17/snippets/), and organize [working
groups/guilds/grouplets](https://github.com/18F/grouplet-playbook/).

You will need [Ruby](https://www.ruby-lang.org) version 2.1.5 or greater. To
run your own local instance at `http://localhost:4000`:

```
$ git clone git@github.com:18F/hub.git
$ cd hub

# Only 18F team members need run this:
$ ./go init

$ ./go serve
```

See the "Hub 101" docs either [in this repository](pages/101/), [served
locally](http://localhost:4000/101/), or on the [18F Public
Hub](https://18f.gsa.gov/hub/101/) for details and tips on how to set up and
work with the Hub development environment.

#### Authentication

If `_config.yml` and not `_config_public.yml` is used,
data will be collected from the team-api's private server
(https://team-api.18f.gov/api), which requires authentication; get
the HMAC shared secret, copy and edit `set_hmac_auth.sample.sh`,
and source the edited file to set the shared secret into
environment variables.

### Contributing

1.  Fork the repo ( https://github.com/18F/hub/fork ). If you're an 18F team member, you'll likely find it easier to clone the repo instead of forking it (`git clone --recursive git@github.com:18F/hub.git`). The recursive clone ensures that you'll grab the contents of private submodules.
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Feel free to ping [@mbland](https://github.com/mbland) with any questions you
may have, especially if the current documentation should've addressed your
needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright
> and related rights in the work worldwide are waived through the [CC0 1.0
> Universal public domain
> dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication.
> By submitting a pull request, you are agreeing to comply with this waiver of
> copyright interest.
