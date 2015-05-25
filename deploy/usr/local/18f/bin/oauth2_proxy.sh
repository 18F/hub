#! /bin/sh
LOGS=/var/log/oauth2_proxy

if [ ! -d $LOGS ]; then
  mkdir -p $LOGS
fi

exec /usr/local/18f/bin/oauth2_proxy "$@" >>$LOGS/access.log 2>&1
