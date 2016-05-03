#!/usr/bin/env bash

OPTION="${1}"

if [ ! -z "${ROOTPATH}" ]; then
  echo ":: We have changed the semantic and doesn't need the ROOTPATH"
  echo ":: variable anymore"
fi

case $OPTION in
  "stop")
    echo "-=> stop matrix"
    echo "-=> via docker stop ..."
    ;;
  "version")
    VERSION=$(tail -n 1 /synapse.version)
    echo "-=> Matrix Version: ${VERSION}"
    ;;
  "start")
    breakup="0"
    [[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
    [[ -z "${TURNKEY}" ]] && echo "STOP! environment variable TURNKEY must be set" && breakup="1"
    [[ "${REPORT_STATS}" != "yes" ]] && [[ "${REPORT_STATS}" != "no" ]] && \
      echo "STOP! REPORT_STATS needs to be 'no' or 'yes'" && breakup="1"
    [[ "${breakup}" == "1" ]] && exit 1


    echo "-=> generate synapse config"
    python -m synapse.app.homeserver \
           --config-path /config/homeserver.yaml \
           --generate-config \
           --report-stats ${REPORT_STATS} \
           --server-name ${SERVER_NAME}

    echo "-=> configure some settings in homeserver.yaml"
    awk -v SERVER_NAME="${SERVER_NAME}" \
        -v TURNURIES="turn_uris: [\"turn:${TURN_SERVER_NAME}:3478?transport=udp\", \"turn:${TURN_SERVER_NAME}:3478?transport=tcp\"]" \
        -v TURNSHAREDSECRET="turn_shared_secret: \"${TURNKEY}\"" \
        -v PIDFILE="pid_file: /data/homeserver.pid" \
        -v DATABASE="database: \"/data/homeserver.db\"" \
        -v LOGFILE="log_file: \"/data/homeserver.log\"" \
        -v MEDIASTORE="media_store_path: \"/data/media_store\"" \
        '{
      sub(/turn_shared_secret: "YOUR_SHARED_SECRET"/, TURNSHAREDSECRET);
      sub(/turn_uris: \[\]/, TURNURIES);
      sub(/pid_file: \/homeserver.pid/, PIDFILE);
      sub(/database: "\/homeserver.db"/, DATABASE);
      sub(/log_file: "\/homeserver.log"/, LOGFILE);
      sub(/media_store_path: "\/media_store"/, MEDIASTORE);
      print;
    }' /config/homeserver.yaml > /config/homeserver.tmp

    # Add ldap stanza to homeserver.yaml
    echo >> /config/homeserver.tmp <<EOF

    ldap_config:
      enabled: true
      server: ${LDAP_URL}
      port: ${LDAP_PORT}
      search_base: ${LDAP_SEARCH_BASE}
      search_property: ${LDAP_SEARCH_PROPERTY}
      email_property: ${LDAP_EMAIL_PROPERTY}
      full_name_property: ${LDAP_FIRST_NAME_PROPERTY}
EOF

    mv /config/homeserver.tmp /config/homeserver.yaml

    echo "-=> start matrix"
    python -m synapse.app.homeserver \
           --config-path /config/homeserver.yaml \
    ;;
  *)
    echo "-=> unknown \'$OPTION\'"
    ;;
esac
