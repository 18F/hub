#! /usr/bin/env ruby
#
# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2015 by Mike Bland (michael.bland@gsa.gov)
# on behalf of the 18F team, part of the US General Services Administration:
# https://18f.gsa.gov/
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software. If not, see
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
# @author Mike Bland (michael.bland@gsa.gov)
#
# ----
#
# ./go script: unified development environment interface 
#
# Inspired by:
# http://www.thoughtworks.com/insights/blog/praise-go-script-part-i
# http://www.thoughtworks.com/insights/blog/praise-go-script-part-ii
#
# Author: Mike Bland (michael.bland@gsa.gov)
# Date:   2015-01-10

MIN_VERSION = "2.1.5"

unless RUBY_VERSION >= MIN_VERSION
  puts <<EOF

*** ABORTING: Unsupported Ruby version ***

Ruby version #{MIN_VERSION} or greater is required to work with the Hub, but
this Ruby is version #{RUBY_VERSION}. Consider using a version manager such as
rbenv (https://github.com/sstephenson/rbenv) or rvm (https://rvm.io/)
to install a Ruby version specifically for Hub development.

EOF
  exit 1
end

def exec_cmd(cmd)
  exit $?.exitstatus unless system(cmd)
end

def init
  begin
    require 'bundler'
  rescue LoadError
    puts "Installing Bundler gem..."
    exec_cmd 'gem install bundler'
    puts "Bundler installed; installing gems"
  end
  update_gems
end

def update_gems
  exec_cmd 'bundle'
end

def test
  exec_cmd 'bundle exec rake test'
end

def serve
  exec 'bundle exec jekyll serve --trace'
end

def serve_public
  exec('bundle exec jekyll serve --trace ' +
    '--config _config.yml,_config_public.yml')
end

def build
  puts 'Building internal version...'
  exec_cmd('bundle exec jekyll b --trace')
  puts 'Building public version...'
  exec_cmd('bundle exec jekyll b --trace ' +
    '--config _config.yml,_config_public.yml')
end

def ci_build
  test
  build
end

AUTOMATED_DEPLOY_PULL_CMD = "git pull && git submodule update --remote"
INTERNAL_BUNDLE_CMD = "/usr/local/rbenv/shims/bundle"
PUBLIC_BUNDLE_CMD = "/opt/install/rbenv/shims/bundle"
JEKYLL_BUILD_CMD = "exec jekyll b"
JEKYLL_PUBLIC_CONFIG = "--config _config.yml,_config_public.yml"

def deploy_submodules
  exec_cmd(AUTOMATED_DEPLOY_PULL_CMD + ' && cd _data && ' +
    '/usr/local/rbenv/shims/ruby ./import-public.rb && cd .. && ' +
    'git add _data/private _data/public/ pages/private && ' +
    'git commit -m \'Private submodule update\' && git push')
end

def deploy_internal
  exec_cmd("%s && %s && %s %s && %s %s %s" % [
    AUTOMATED_DEPLOY_PULL_CMD,
    INTERNAL_BUNDLE_CMD,
    INTERNAL_BUNDLE_CMD, JEKYLL_BUILD_CMD,
    INTERNAL_BUNDLE_CMD, JEKYLL_BUILD_CMD, JEKYLL_PUBLIC_CONFIG])
end

def deploy_public
  exec_cmd("%s && %s && %s %s %s" % [
    AUTOMATED_DEPLOY_PULL_CMD,
    PUBLIC_BUNDLE_CMD,
    PUBLIC_BUNDLE_CMD, JEKYLL_BUILD_CMD, JEKYLL_PUBLIC_CONFIG])
end

COMMANDS = {
  :init => 'Set up the Hub dev environment',
  :update_gems => 'Execute Bundler to update gem set',
  :test => 'Execute automated tests',
  :serve => 'Serves the internal hub at localhost:4000',
  :serve_public => 'Serves the public hub at localhost:4000/hub/',
  :build => 'Builds the internal and external versions of the Hub',
  :ci_build => 'Runs tests and builds both Hub versions',
}

AUTOMATED_DEPLOYMENT_COMMANDS = {
  :deploy_submodules => 'Commits automated submodule updates',
  :deploy_internal => 'Deploys the internal and staging Hub instances',
  :deploy_public => 'Deploys the public Hub instance',
}

COMMAND_SECTIONS = [
  {:section => 'Development commands',
   :commands => COMMANDS},
  {:section => 'Automated deployment commands used by deploy/fabfile.py',
   :commands => AUTOMATED_DEPLOYMENT_COMMANDS},
]

def usage(exitstatus: 0)
  puts <<EOF
Usage: #{$0} [options] [command]

options:
  -h,--help  Show this help
EOF

  COMMAND_SECTIONS.each do |command_section|
    puts "\n#{command_section[:section]}:"
    commands = command_section[:commands]
    padding = commands.keys.max_by {|i| i.size}.size + 2
    commands.each {|name, desc| puts "  %-#{padding}s#{desc}" % name}
  end
  exit exitstatus
end

usage(exitstatus: 1) unless ARGV.size == 1
command = ARGV.shift
usage if ['-h', '--help'].include? command

command = command.to_sym
ALL_GO_COMMANDS = COMMAND_SECTIONS.map {|i| i[:commands].keys}.flatten
unless ALL_GO_COMMANDS.member? command
  puts "Unknown option or command: #{command}"
  usage(exitstatus: 1)
end
send command
