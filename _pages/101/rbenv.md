---
title: Hub 101 - Setting up the Ruby environment with `rbenv`
---
# {{ page.title }}

Using [rbenv](https://github.com/sstephenson/rbenv) helps ensure a stable Ruby
version during development. `rbenv` is also used to deploy the Hub and
18f.gsa.gov. ([rvm](https://rvm.io/) is another Ruby version manager preferred
by some, but installing `rvm` instead of `rbenv` is left as an exercise for
the reader.)

In the following example, we'll install `rbenv` under `/usr/local/rbenv`.
Replace `~/.bashrc` with the appropriate configuration file for your shell:

```shell
$ export RBENV_ROOT=/usr/local/rbenv
$ sudo mkdir $RBENV_ROOT
$ sudo chown $USER $RBENV_ROOT
$ git clone https://github.com/sstephenson/rbenv.git $RBENV_ROOT
$ echo 'export RBENV_ROOT=/usr/local/rbenv' >> ~/.bashrc
$ echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
$ source ~/.bashrc
```

To more easily install and manage Ruby versions using `rbenv`, we'll also
install the [`ruby-build` plugin](https://github.com/sstephenson/ruby-build):

```shell
$ cd $RBENV_ROOT
$ git pull
$ git clone https://github.com/sstephenson/ruby-build.git \
  $RBENV_ROOT/plugins/ruby-build
$ rbenv rehash
```

Now we're ready to install the Ruby version of our choice. Versions 2.1.5 and
above are recommended for developing the Hub (we'll install version 2.2.0 in
the example below):

```shell
$ rbenv install -l | grep '  2\.[12]'
  2.1.0-dev
  2.1.0-preview1
  2.1.0-preview2
  2.1.0-rc1
  2.1.0
  2.1.1
  2.1.2
  2.1.3
  2.1.4
  2.1.5
  2.2.0-dev
  2.2.0-preview1
  2.2.0-preview2
  2.2.0-rc1
  2.2.0

$ rbenv install 2.2.0
[time passes...]

$ rbenv global 2.2.0
```
