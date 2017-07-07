#!/usr/bin/env bash -ex
# these scripts comes (and have been slightly modified from the docker images used in this guide: https://medium.com/@basilio.vera/docker-swarm-metrics-in-prometheus-e02a6a5745a

: ${GF_SECURITY_ADMIN_USER:=admin}
: ${GF_SECURITY_ADMIN_PASSWORD:=admin}

curl -s "http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:3000/api/datasources" \
  -X POST -H 'Content-Type: application/json;charset=UTF-8' \
  --data-binary "{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"url\":\"${PROMETHEUS_ENDPOINT}\",\"access\":\"proxy\",\"isDefault\":true}"
