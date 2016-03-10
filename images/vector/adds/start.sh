#!/usr/bin/env bash

OPTION="${1}"

case $OPTION in
	"start")
		echo "-=> start vector.im client"
		(
			if [ -f /data/vector.im.conf ]; then
				options=""

				while read -r line; do
					[ "${line:0:1}" == "#" ] && continue
					[ "${line:0:1}" == " " ] && continue
					options="${options} ${line}"
				done < /data/vector.im.conf

				cd /vector-web/vector
				echo "-=> vector.im options: http-server ${options}"
				http-server ${options}
			fi
		)
                ;;

	"generate")
		breakup="0"
		[[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
		[[ "${breakup}" == "1" ]] && exit 1

		echo "-=> generate vector.im server config"
		echo "# change this option to your needs" >> /data/vector.im.conf
		echo "-p 8080" > /data/vector.im.conf
		echo "-a 0.0.0.0" >> /data/vector.im.conf
		echo "-c 3500" >> /data/vector.im.conf
		echo "--ssl" >> /data/vector.im.conf
		echo "--cert /data/${SERVER_NAME}.tls.crt" >> /data/vector.im.conf
		echo "--key /data/${SERVER_NAME}.tls.key" >> /data/vector.im.conf

		echo "-=> you can now review the generated configuration file vector.im.conf"
		;;
	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac
