#! /usr/bin/env python2.7
#
# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2014 by Mike Bland (michael.bland@gsa.gov)
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

"""
Manage auto-deploy webhooks for the public Hub.

See the "Preparing for automated deployment" section of the README.md for
instructions.

Author/Thief: Mike Bland (michael.bland@gsa.gov)
Date:         2014-12-18
"""

import time
import fabric.api

# Specifies the hook to manage. Defaults to internal; override with:
#   fab [command] --set instance=public"
INSTANCE = fabric.api.env.get('instance', 'internal')

INTERNAL_RUBY_CMD = "/usr/local/rbenv/shims/ruby"
PUBLIC_RUBY_CMD = "/opt/install/rbenv/shims/ruby"

SETTINGS = {
  'internal': {
    'host': '18f-hub', 'port': 4000, 'home': '/home/ubuntu',
    'branch': 'master',
    'cmd': "%s ./go deploy_internal " % INTERNAL_RUBY_CMD,
  },
  'submodules': {
    'host': '18f-hub', 'port': 4001, 'home': '/home/ubuntu',
    'branch': 'master',
    'cmd': "%s ./go deploy_submodules " % INTERNAL_RUBY_CMD,
  },
  'public': {
    'host': '18f-site', 'port': 4002, 'home': '/home/site/production',
    'branch': 'production-public',
    'cmd': "%s ./go deploy_public " % PUBLIC_RUBY_CMD,
  },
}[INSTANCE]

LOG = "%s/hub.log" % SETTINGS['home']
REMOTE_REPO_DIR = "%s/hub" % SETTINGS['home']

fabric.api.env.use_ssh_config = True
fabric.api.env.hosts = [SETTINGS['host']]

COMMAND = "cd %s && %s >> %s" % (REMOTE_REPO_DIR, SETTINGS['cmd'], LOG)

def start():
  fabric.api.run(
    "cd %s && forever start -l %s -a deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (REMOTE_REPO_DIR, LOG, SETTINGS['port'], SETTINGS['branch'], COMMAND)
  )

def stop():
  fabric.api.run(
    "cd %s && forever stop deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (REMOTE_REPO_DIR, SETTINGS['port'], SETTINGS['branch'], COMMAND)
  )

def restart():
  fabric.api.run(
    "cd %s && forever restart deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (REMOTE_REPO_DIR, SETTINGS['port'], SETTINGS['branch'], COMMAND)
  )

def start_prose():
  fabric.api.env.hosts = ['18f-hub']
  fabric.api.run("forever start -l gatekeeper.log -a gatekeeper/server.js")
  fabric.api.run("forever start -l prose.log -a -c /usr/local/bin/serve prose")

def stop_prose():
  fabric.api.env.hosts = ['18f-hub']
  fabric.api.run("forever stop gatekeeper/server.js")
  fabric.api.run("forever stop -c /usr/local/bin/serve prose")
