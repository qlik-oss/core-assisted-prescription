#!/usr/bin/env bash -ex
# these scripts comes (and have been slightly modified from the docker images used in this guide: https://medium.com/@basilio.vera/docker-swarm-metrics-in-prometheus-e02a6a5745a

: ${GF_SECURITY_ADMIN_USER:=admin}
: ${GF_SECURITY_ADMIN_PASSWORD:=admin}

if [ ${DASHBOARDS_IMPORT} ]; then

    dashboard=$(echo $DASHBOARDS_IMPORT | tr "," "\n")
    for dash in $dashboard
    do
        dashboard_id=${dash/:*/}
        dashboard_version=${dash/*:/}

        echo "DASH ID: $dashboard_id - $dashboard_version"
        curl -s "https://grafana.net/api/dashboards/${dashboard_id}/revisions/${dashboard_version}/download" > /tmp/dashboard_data.json
        echo "{ \"dashboard\": $(cat /tmp/dashboard_data.json), \"overwrite\": true }" > /tmp/dashboard_data2.json
        sed 's/${DS_PROMETHEUS}/Prometheus/g' /tmp/dashboard_data2.json > /tmp/dashboard_data3.json
set -ex
        curl \
            -X POST -H 'Content-Type: application/json;charset=UTF-8' \
            -d @/tmp/dashboard_data3.json \
            "http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:3000/api/dashboards/db"
    done
fi
