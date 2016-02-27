#!/usr/bin/env bash

OPTION="${1}"

case $OPTION in
	"start")
		if [ -f /data/turnserver.conf ]; then
			echo "-=> start turn"
			/usr/local/bin/turnserver -c /data/turnserver.conf
		fi
		;;

	"generate")
		breakup="0"
		[[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
		[[ "${breakup}" == "1" ]] && exit 1

		export TURNKEY=$(pwgen -s 64 1)
		echo "-=> generate turn config"
		echo "lt-cred-mech" > /data/turnserver.conf
		echo "use-auth-secret" >> /data/turnserver.conf
		echo "static-auth-secret=${TURNKEY}" >> /data/turnserver.conf
		echo "realm=turn.${SERVER_NAME}" >> /data/turnserver.conf
		echo "cert=/data/${SERVER_NAME}.tls.crt" >> /data/turnserver.conf
		echo "pkey=/data/${SERVER_NAME}.tls.key" >> /data/turnserver.conf

                echo "${TURNKEY}" > /data/TURNKEY

		echo "-=> you can now review the generated configuration file turnserver.conf"
		;;

	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac

