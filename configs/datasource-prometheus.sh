#!/usr/bin/env bash -ex

: ${GF_SECURITY_ADMIN_USER:=admin}

curl -s "http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:3000/api/datasources" \
  -X POST -H 'Content-Type: application/json;charset=UTF-8' \
  --data-binary "{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"url\":\"${PROMETHEUS_ENDPOINT}\",\"access\":\"proxy\",\"isDefault\":true}"
