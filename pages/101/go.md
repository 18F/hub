---
title: Hub 101 - Using the `./go` Script
permalink: /101/go/
---
# {{ page.title }}

The `./go` script sets up the Hub development environment and contains the
most common development commands. It was inspired by a pair of blog posts
by Pete Hodgson of ThoughtWorks, [In Praise of the ./go Script - Part
I](http://www.thoughtworks.com/insights/blog/praise-go-script-part-i) and [In
Praise of the ./go Script - Part
II](http://www.thoughtworks.com/insights/blog/praise-go-script-part-ii).

Run `./go` in the root directory of the Hub repository for a list of
available commands. The `test`, `serve`, and `serve_public` commands are the
most common for routine development.

While it's expected that the `./go` script will change with the times, the
basic information here should remain valid regardless. (The one exception to
this might be whether or not we eventually pass arguments to individual `./go`
commands.)

## Initializing the environment

Run the following to install the [Bundler gem](http://bundler.io/) and all the
other gems currently required by the Hub:

```shell
$ ./go init
```

Required gems are listed in the `Gemfile`. `bundler` stores specific versions
of these gems in the `Gemfile.lock` file. See the [Bundler Gemfile
docs](http://bundler.io/gemfile.html) for details on the format of these
files.

**For 18F team members:** Run the following to initialize the `_data/private`
and `pages/private` submodules:

```shell
$ git submodule init
$ git submodule update
```
See [Git Submodules](git-submodules/) for more details.

## Serving the Hub locally

See [Internal vs. Public Hubs](internal-vs-public/) for the difference between
the "internal" and "public" versions of the Hub:

```shell
# To serve the internal Hub at http://localhost:4000/
$ ./go serve

# To serve the public Hub at https://localhost:4000/hub/
$ ./go serve_public
```

## Running the test suite

If you're working on the plugin code (in `_plugins`), you can run the entire
test suite with:

```shell
$ ./go test
```

## Updating Gems

Whether you've added a new Gem requirement to the `Gemfile` or you wish to
import new versions of existing gems, you can update the existing Gem set and
the `Gemfile.lock` file by running:

```shell
$ ./go update_gems
```

## Under the Hood

Each `./go` command corresponds to a function of the same name within the
`./go` script. None of the commands take arguments currently; you may wish to
look inside the `./go` script to see the underlying commands and use them
directly with different arguments.
