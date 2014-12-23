#! /bin/bash
#
# This is temporary until we set up a proper hookshot+webhoook deployment just
# like 18f.gsa.gov.

# Hack per:
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd $(dirname $0) >/dev/null
HUB_ROOT=$(dirname $(pwd -P))
popd >/dev/null

REMOTE="ubuntu@18f-site:/home/site/production/hub"
rsync -e ssh -vaxp --delete --ignore-errors $HUB_ROOT/_site_public $REMOTE
