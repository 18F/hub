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

# Specifies the hook to manage, based on the name of the corresponding branch
# within https://github.com/18F/hub. Defaults to internal; override with:
#   fab [command] --set branch=production-public"
BRANCH = fabric.api.env.get('branch', 'staging-public')

SETTINGS = {
  'staging-public': {
    'port': 4001, 'host': '18f-hub', 'home': '/home/ubuntu',
    'config': '_config.yml,_config_public.yml'
  },
  'production-public': {
    'port': 4002, 'host': '18f-site', 'home': '/home/site',
    'config': '_config.yml,_config_public.yml'
  },
}[BRANCH]

LOG = "%s/hub-%s.log" % (SETTINGS['home'], BRANCH)
BRANCH_REPO = "%s/hub-%s" % (SETTINGS['home'], BRANCH)

fabric.api.env.use_ssh_config = True
fabric.api.env.hosts = [SETTINGS['host']]

COMMAND = "cd %s && git pull && bundle exec jekyll b --config %s >> %s" % (
  BRANCH_REPO, SETTINGS['config'], LOG)

def start():
  fabric.api.run(
    "cd %s && forever start -l %s -a deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (BRANCH_REPO, LOG, SETTINGS['port'], BRANCH, COMMAND)
  )

def stop():
  fabric.api.run(
    "cd %s && forever stop deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (BRANCH_REPO, SETTINGS['port'], BRANCH, COMMAND)
  )

def restart():
  fabric.api.run(
    "cd %s && forever restart deploy/hookshot.js -p %i -b %s -c \"%s\""
    % (BRANCH_REPO, SETTINGS['port'], BRANCH, COMMAND)
  )
