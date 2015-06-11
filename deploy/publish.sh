#! /bin/bash
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
#
# ----
#
# This is temporary until we set up a proper hookshot+webhoook deployment just
# like 18f.gsa.gov.

# Hack per:
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd $(dirname $0) >/dev/null
HUB_ROOT=$(dirname $(pwd -P))
popd >/dev/null

REMOTE="ubuntu@hub.18f.gov:18f-hub"
rsync -e ssh -vaxp --delete --ignore-errors $HUB_ROOT/_site{,_public} $REMOTE
