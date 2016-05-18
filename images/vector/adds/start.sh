#!/usr/bin/env bash

OPTION="${1}"

case $OPTION in
	"start")
			(cd vector-web/vector && http-server -p 8080 -a 0.0.0.0 -c 3500)
                ;;
esac
