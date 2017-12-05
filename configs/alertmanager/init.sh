#!/bin/sh -e

SLACK_WEBHOOK=`cat /run/secrets/slack_webhook`
cat /tmp/config.yml | sed "s@<slackapi>@'$SLACK_WEBHOOK'@g" > /etc/alertmanager/config.yml

# Will add path to alertmanager and passed commands (config file) after.
set -- "/bin/alertmanager" "$@"

exec "$@"
