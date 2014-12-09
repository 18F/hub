#! /bin/bash

# Hack per:
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd $(dirname $0) >/dev/null
HUB_ROOT=$(dirname $(pwd -P))
popd >/dev/null

REMOTE="ubuntu@hub.18f.us:18f-hub"
rsync -e ssh -vaxp --delete --ignore-errors $HUB_ROOT/_site{,_public} $REMOTE
