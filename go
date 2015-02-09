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

require 'digest'

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
  exec_cmd 'bundle install'
end

def update_components
  exec_cmd 'npm install -g bower bower-installer'
  exec_cmd 'bower update'
  exec_cmd 'bower-installer'
end

def update_gems
  exec_cmd 'bundle update'
  exec_cmd 'git add Gemfile.lock'
end

def test
  exec_cmd 'bundle exec rake test'
end

JEKYLL_BUILD_CMD = "exec jekyll build --trace"
JEKYLL_SERVE_CMD = "exec jekyll serve --trace"
JEKYLL_PUBLIC_CONFIG = "--config _config.yml,_config_public.yml"

def serve
  exec "bundle #{JEKYLL_SERVE_CMD}"
end

def serve_public
  exec "bundle #{JEKYLL_SERVE_CMD} #{JEKYLL_PUBLIC_CONFIG}"
end

def build
  puts 'Building internal version...'
  exec_cmd "bundle #{JEKYLL_BUILD_CMD}"
  puts 'Building public version...'
  exec_cmd "bundle #{JEKYLL_BUILD_CMD} #{JEKYLL_PUBLIC_CONFIG}"
end

def ci_build
  test
  build
end

def deploy(deploy_commands)
  exec_cmd(['git pull',
            'git submodule update --remote',
           ].concat(deploy_commands).join(' && '))
end

def deploy_submodules
  deploy([
    '/usr/local/rbenv/shims/ruby _data/import-public.rb',
    'git add .',
    'git commit -m \'Private submodule update\'',
    'git push',
  ])
end

def deploy_internal
  auth_emails_path = '_site/auth/hub-authenticated-emails.txt'
  users_digest = ::Digest::SHA256.file auth_emails_path

  bundle_cmd = "/usr/local/rbenv/shims/bundle"
  deploy([
    "#{bundle_cmd} install",
    "#{bundle_cmd} #{JEKYLL_BUILD_CMD}",
    "#{bundle_cmd} #{JEKYLL_BUILD_CMD} #{JEKYLL_PUBLIC_CONFIG}",
  ])

  if ::Digest::SHA256.file(auth_emails_path) != users_digest
    exec_cmd('sudo service google_auth_proxy restart')
  end
end

def deploy_public
  bundle_cmd = "/opt/install/rbenv/shims/bundle"
  deploy([
    "#{bundle_cmd} install",
    "#{bundle_cmd} #{JEKYLL_BUILD_CMD} #{JEKYLL_PUBLIC_CONFIG}",
  ])
end

# Groups a set of commands by common function.
class CommandGroup
  attr_accessor :description, :commands
  private_class_method :new
  @@groups = Array.new

  # @param description [String] short description of the group
  # @param commands [Hash<Symbol,String>] mapping from command function name
  #   to a brief description; each key must be the name of a function in this
  #   script
  def initialize(description, commands)
    @description = description
    @commands = commands
  end

  def to_s
    padding = @commands.keys.max_by {|i| i.size}.size + 2
    ["\n#{@description}"].concat(
      @commands.map {|name, desc| "  %-#{padding}s#{desc}" % name}).join("\n")
  end

  def self.add_group(description, commands)
    @@groups << new(description, commands)
  end

  def self.groups
    @@groups
  end

  def self.check_command_exists(command_symbol)
    all_commands = @@groups.map {|i| i.commands.keys}.flatten
    unless all_commands.member? command_symbol
      puts "Unknown option or command: #{command_symbol}"
      usage(exitstatus: 1)
    end
  end
end

CommandGroup.add_group(
  'Development commands',
  {
    :init => 'Set up the Hub dev environment',
    :update_components => 'Execute bower-installer to update Bower components. Requires Node.js.',
    :update_gems => 'Execute Bundler to update gem set',
    :test => 'Execute automated tests',
    :serve => 'Serves the internal hub at localhost:4000',
    :serve_public => 'Serves the public hub at localhost:4000/hub/',
    :build => 'Builds the internal and external versions of the Hub',
    :ci_build => 'Runs tests and builds both Hub versions',
  })

CommandGroup.add_group(
  'Automated deployment commands used by deploy/fabfile.py',
  {
    :deploy_submodules => 'Commits automated submodule updates',
    :deploy_internal => 'Deploys the internal and staging Hub instances',
    :deploy_public => 'Deploys the public Hub instance',
  }
)

def usage(exitstatus: 0)
  puts <<EOF
Usage: #{$0} [options] [command]

options:
  -h,--help  Show this help
EOF
  CommandGroup.groups.each {|s| puts s}
  exit exitstatus
end

usage(exitstatus: 1) unless ARGV.size == 1
command = ARGV.shift
usage if ['-h', '--help'].include? command

command = command.to_sym
CommandGroup.check_command_exists command
send command
