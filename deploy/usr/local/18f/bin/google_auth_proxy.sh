#! /bin/sh
LOGS=/var/log/google_auth_proxy

if [ ! -d $LOGS ]; then
  mkdir -p $LOGS
fi

exec /usr/local/18f/bin/google_auth_proxy "$@" >>$LOGS/access.log 2>&1
