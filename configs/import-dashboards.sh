#!/usr/bin/env bash

: ${GF_SECURITY_ADMIN_USER:=admin}

if [ ${DASHBOARDS_IMPORT} ]; then

    dashboard=$(echo $DASHBOARDS_IMPORT | tr "," "\n")

    for dash in $dashboard
    do
        dashboard_id=${dash/:*/}
        dashboard_version=${dash/*:/}

        echo "DASH ID: $dashboard_id - $dashboard_version"
        curl -s "https://grafana.net/api/dashboards/${dashboard_id}/revisions/${dashboard_version}/download" > /tmp/dashboard_data.json
        echo "{ \"dashboard\": "$(cat /tmp/dashboard_data.json)", \"overwrite\": true }" > /tmp/dashboard_data2.json
        sed -i.bak "s/\\${DS_PROMETHEUS}/${PROMETHEUS_ENDPOINT}/g" /tmp/dashboard_data2.json
set -ex
        curl \
            -X POST -H 'Content-Type: application/json;charset=UTF-8' \
            -d @/tmp/dashboard_data2.json \
            "http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:3000/api/dashboards/db"
    done
fi
