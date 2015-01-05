#!/usr/bin/env node
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
# Original author: Eric Mill

var hookshot = require("hookshot");
var spawn = require("child_process").spawn;
var options = require('minimist')(process.argv.slice(2));

var branch = options.b || options.branch;
var command = options.c || options.command;
var port = options.p || options.port;

if (!branch || !command || !port) {
  console.error("--branch, --command, and --port are all required.")
  process.exit(1);
}

hookshot('refs/heads/' + branch, command).listen(port);

console.log("18F Hub: Listening on port " + port + " for push events on " + branch + ".")
