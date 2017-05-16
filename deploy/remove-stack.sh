#!/bin/bash
USERNAME=$(id -u -n)

eval $(docker-machine env $USERNAME-docker-manager1)
docker stack rm custom-analytics
