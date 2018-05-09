#!/bin/sh
set -e

getServiceIP () {
    nslookup "$1" 2>/dev/null | grep -oE '(([0-9]{1,3})\.){3}(1?[0-9]{1,3})'
}

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"9.9.9.9"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
if [ -n "$(getServiceIP unbound)" ]; then
    UNBOUND_SERVICE_HOST=$(getServiceIP unbound)
fi
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"

if [ $# -eq 0 ]; then
    exec /usr/local/bin/doh-proxy -u "${RESOLVER}" -l 0.0.0.0:3000
fi

[ "$1" = '--' ] && shift

# Silence "DDUT server error: Incomplete" log messages
# https://github.com/jedisct1/rust-doh/blob/d2bc3e24491498f17036fe0c02b1dc2e76d38f2f/src/main.rs#L97
exec /usr/local/bin/doh-proxy "$@" 2>/dev/null
