#!/bin/sh -e

echo "Setting up Slack $SLACK_URL' '$SLACK_CHANNEL'"

cat /etc/alertmanager/alertmanager.yml |\
    sed "s@#api_url: <url>#@api_url: '$SLACK_URL'@g" |\
    sed "s@#channel: <channel>#@channel: '$SLACK_CHANNEL'@g" > /tmp/alertmanager.yml

mv /tmp/alertmanager.yml /etc/alertmanager/alertmanager.yml

cat /etc/alertmanager/alertmanager.yml

set -- /bin/alertmanager "$@"

exec "$@"
