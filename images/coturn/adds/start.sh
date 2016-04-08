#!/usr/bin/env bash

OPTION="${1}"

case $OPTION in
	"start")
		breakup="0"
		[[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
		[[ -z "${TURNKEY}" ]] && echo "STOP! environment variable TURNKEY must be set" && breakup="1"
		[[ "${breakup}" == "1" ]] && exit 1

		echo "-=> generate turn config"
		echo "lt-cred-mech" > /config/turnserver.conf
		echo "use-auth-secret" >> /config/turnserver.conf
		echo "static-auth-secret=${TURNKEY}" >> /config/turnserver.conf
		echo "realm=turn.${SERVER_NAME}" >> /config/turnserver.conf
		echo "cert=/data/ssl.crt" >> /config/turnserver.conf
		echo "pkey=/data/ssl.key" >> /config/turnserver.conf

		echo "-=> start turn"
		/usr/local/bin/turnserver -c /config/turnserver.conf
		;;

	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac
