#!/usr/bin/env bash -ex

: ${GF_SECURITY_ADMIN_USER:=admin}

curl -s "http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:3000/api/datasources" \
  -X POST -H 'Content-Type: application/json;charset=UTF-8' \
  --data-binary "{\"name\":\"ElasticSearch - Logs\",\"type\":\"elasticsearch\",\"url\":\"${ELASTICSEARCH_ENDPOINT}\",\"access\":\"proxy\",\"isDefault\":false,\"database\":\"logstash-logs\",\"basicAuth\":true,\"basicAuthUser\":\"${ELASTICSEARCH_USER}\",\"basicAuthPassword\":\"${ELASTICSEARCH_PASSWORD}\"}"

curl -s "http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:3000/api/datasources" \
  -X POST -H 'Content-Type: application/json;charset=UTF-8' \
  --data-binary "{\"name\":\"ElasticSearch - Alerts\",\"type\":\"elasticsearch\",\"url\":\"${ELASTICSEARCH_ENDPOINT}\",\"access\":\"proxy\",\"isDefault\":false,\"database\":\"logstash-alerts\",\"basicAuth\":true,\"basicAuthUser\":\"${ELASTICSEARCH_USER}\",\"basicAuthPassword\":\"${ELASTICSEARCH_PASSWORD}\"}"
