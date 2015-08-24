#! /usr/bin/env ruby

require 'English'

Dir.chdir File.dirname(__FILE__)

def try_command_and_restart(command)
  exit $CHILD_STATUS.exitstatus unless system command
  exec $PROGRAM_NAME, *ARGV
end

begin
  require 'bundler/setup' if File.exist? 'Gemfile'
rescue LoadError
  try_command_and_restart 'gem install bundler'
rescue SystemExit
  try_command_and_restart 'bundle install'
end

begin
  require 'go_script'
rescue LoadError
  try_command_and_restart 'gem install go_script'
end

extend GoScript
check_ruby_version '2.1.5'

command_group :dev, 'Development commands'

def_command :update_gems, 'Update Ruby gems' do |gems = []|
  update_gems gems
end

def_command :update_js, 'Update JavaScript components' do
  update_node_modules
  exec_cmd 'gulp vendorize'
end

def_command :test, 'Execute automated tests' do |args = []|
  exec_cmd "bundle exec rake test #{args.join ' '}"
end

JEKYLL_PUBLIC_CONFIG = "--config _config.yml,_config_public.yml"

def_command :serve, 'Serves the internal hub at localhost:4000' do
  serve_jekyll ''
end

def_command :serve_public, 'Serves the public hub at localhost:4000/hub' do
  serve_jekyll JEKYLL_PUBLIC_CONFIG
end

def_command :build, 'Builds the internal and external versions of the Hub' do
  puts 'Building internal version...'
  build_jekyll ''
  puts 'Building public version...'
  build_jekyll JEKYLL_PUBLIC_CONFIG
end

def_command :ci_build, 'Runs tests and builds both Hub versions' do
  test
  build
end

command_group :deploy, 'Automated deployment commands used by deploy/fabfile.py'

def deploy(commands = [])
  git_sync_and_deploy ['git submodule update --remote'].concat(commands)
end

def_command :deploy_submodules, 'Commits automated submodule updates' do
  deploy([
    'ruby _data/import-public.rb',
    'git add .',
    'git commit -m \'Private submodule update\'',
    'git push',
  ])
end

def_command(:deploy_internal,
  'Deploys the internal and staging Hub instances') do
  deploy
  build
end

def_command :deploy_public, 'Deploys the public Hub instance' do
  deploy
  build_jekyll JEKYLL_PUBLIC_CONFIG
end

execute_command ARGV
