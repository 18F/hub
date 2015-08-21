#! /usr/bin/env ruby

require 'English'

begin
  require 'go_script'
rescue LoadError
  puts 'Installing go_script gem...'
  exit $CHILD_STATUS.exitstatus unless system 'gem install go_script'
  exec $PROGRAM_NAME, *ARGV
end

GoScript::Version.check_ruby_version '2.1.5'

extend GoScript

dev_commands = GoScript::CommandGroup.add_group 'Development commands'

def_command :init, dev_commands, 'Set up the development environment' do
  install_bundle
end

def_command :update_gems, dev_commands, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :update_js, dev_commands, 'Update JavaScript components' do
  update_node_modules
  exec_cmd 'gulp vendorize'
end

def_command :test, dev_commands, 'Execute automated tests' do |args|
  exec_cmd "bundle exec rake test #{args.join ' '}"
end

JEKYLL_PUBLIC_CONFIG = "--config _config.yml,_config_public.yml"

def_command :serve, dev_commands, 'Serves the internal hub at localhost:4000' do
  serve_jekyll ''
end

def_command(:serve_public, dev_commands,
  'Serves the public hub at localhost:4000/hub') do
  serve_jekyll JEKYLL_PUBLIC_CONFIG
end

def_command(:build, dev_commands,
  'Builds the internal and external versions of the Hub') do
  puts 'Building internal version...'
  build_jekyll ''
  puts 'Building public version...'
  build_jekyll JEKYLL_PUBLIC_CONFIG
end

def_command(:ci_build, dev_commands,
  'Runs tests and builds both Hub versions') do
  test []
  build []
end

deploy_commands = GoScript::CommandGroup.add_group(
  'Automated deployment commands used by deploy/fabfile.py')

def deploy(commands)
  git_sync_and_deploy ['git submodule update --remote'].concat(commands)
end

def_command(:deploy_submodules, deploy_commands,
  'Commits automated submodule updates') do
  deploy([
    'ruby _data/import-public.rb',
    'git add .',
    'git commit -m \'Private submodule update\'',
    'git push',
  ])
end

def_command(:deploy_internal, deploy_commands,
  'Deploys the internal and staging Hub instances') do
  deploy []
  build
end

def_command(:deploy_public, deploy_commands,
  'Deploys the public Hub instance') do
  deploy []
  build_jekyll JEKYLL_PUBLIC_CONFIG
end

execute_command ARGV
