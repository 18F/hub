#! /usr/bin/env python2.7
"""
Manage auto-deploy webhooks for the public Hub.

Author/Thief: Mike Bland (michael.bland@gsa.gov)
Date:         2014-12-18

INSTALLING FABRIC
-----------------
On your local machine, using the system Python:

$ sudo easy_install pip
$ sudo pip install fabric

SSH CONFIG
----------
Make sure your $HOME/.ssh/config file contains the following entries:

Host 18f-site
   Hostname 18f.gsa.gov
   User site
   IdentityFile [INSERT $HOME]/.ssh/[INSERT KEY]
   IdentitiesOnly yes

Host 18f-hub
   Hostname hub.18f.us
   User ubuntu
   IdentityFile [INSERT $HOME]/.ssh/[INSERT KEY]
   IdentitiesOnly yes

INSTALLING NODE REMOTELY
------------------------
On Eric Mill's advice, for Ubuntu, download the latest Node binary and install
it directly on the machine, e.g.:

$ ssh 18f-hub
$ wget http://nodejs.org/dist/v1.10.34/node-v0.10.34-linux-x64.tar.gz
$ gzip -dc node-v0.10.34-linux-x64.tar.gz | tar xf -
$ sudo cp node-v0.10.34-linux-x64/bin/node /usr/local/bin

INSTALLING NODE DEPENDENCIES
----------------------------
On your local machine and on the remote server:

$ npm install hookshot
$ npm install minimist
$ npm install -g forever

INITIAL CLONING
---------------
Before deploying, ssh into each deployment host and clone the repo based on
the appropriate branch:

$ ssh 18f-hub
$ git clone https://github.com/18F/hub.git --branch BRANCH hub-BRANCH

LAUNCH
------
In the same directory as this file, run:

$ fab start

Same deal with "stop" and "restart".
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
  },
  'production-public': {
    'port': 4002, 'host': '18f-site', 'home': '/home/site',
  },
}[BRANCH]

LOG = "%s/hub-%s.log" % (SETTINGS['home'], BRANCH)
BRANCH_REPO = "%s/hub-%s" % (SETTINGS['home'], BRANCH)

fabric.api.env.use_ssh_config = True
fabric.api.env.hosts = [SETTINGS['host']]

COMMAND = "cd %s && git pull && jekyll build >> %s" % (BRANCH_REPO, LOG)

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
