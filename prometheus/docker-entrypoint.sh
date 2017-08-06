#!/bin/sh -e

cat /etc/prometheus/weave-cortext.yml | \
    sed "s@#password: <token>#@password: '$WEAVE_TOKEN'@g" > /tmp/weave-cortext.yml

mv /tmp/weave-cortext.yml /etc/prometheus/weave-cortext.yml

set -- /bin/prometheus "$@"

exec "$@"

