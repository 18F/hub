#! /usr/bin/env python2.7
"""
Manage auto-deploy webhooks for the public Hub.

See the "Preparing for automated deployment" section of the README.md for
instructions.

Author/Thief: Mike Bland (michael.bland@gsa.gov)
Date:         2014-12-18
"""

import time
import fabric.api

# Specifies the hook to manage, based on the name of the corresponding branch
# within https://github.com/18F/hub. Defaults to internal; override with:
#   fab [command] --set branch=production-public"
BRANCH = fabric.api.env.get('branch', 'staging-public')

SETTINGS = {
  'staging-public': {
    'port': 4001, 'host': '18f-hub', 'home': '/home/ubuntu/staging-public',
    'config': '_config.yml,_config_public.yml'
  },
  'production-public': {
    'port': 4002, 'host': '18f-site', 'home': '/home/site/production',
    'config': '_config.yml,_config_public.yml'
  },
}[BRANCH]

LOG = "%s/hub.log" % SETTINGS['home']
REMOTE_REPO_DIR = "%s/hub" % SETTINGS['home']

fabric.api.env.use_ssh_config = True
fabric.api.env.hosts = [SETTINGS['host']]

COMMAND = "cd %s && git pull && bundle exec jekyll b --config %s >> %s" % (
  REMOTE_REPO_DIR, SETTINGS['config'], LOG)

def start():
  fabric.api.run(
    "cd %s && forever start -l %s -a deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (REMOTE_REPO_DIR, LOG, SETTINGS['port'], BRANCH, COMMAND)
  )

def stop():
  fabric.api.run(
    "cd %s && forever stop deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (REMOTE_REPO_DIR, SETTINGS['port'], BRANCH, COMMAND)
  )

def restart():
  fabric.api.run(
    "cd %s && forever restart deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (REMOTE_REPO_DIR, SETTINGS['port'], BRANCH, COMMAND)
  )
