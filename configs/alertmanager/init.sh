#!/bin/sh -e

cat /tmp/config.yml | sed "s@<slackapi>@'$SLACK_API'@g" > /etc/alertmanager/config.yml

# Will add path to alertmanager and passed commands (config file) after.
set -- "/bin/alertmanager" "$@"

exec "$@"
