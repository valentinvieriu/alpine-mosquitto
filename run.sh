#!/bin/sh
set -e

chown mosquitto:mosquitto -R /var/lib/mosquitto
# chown mosquitto:mosquitto -R /etc/mosquitto/tls

if [ "$1" = 'mosquitto' ]; then
	#if [ -z "$(ls -A "$PGDATA")" ]; then
	#fi

	exec /usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
fi

exec "$@"
