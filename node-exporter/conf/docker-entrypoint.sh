#!/bin/sh -e

echo "node_id{node_id=\"$NODE_ID\"} 1" > /etc/node-exporter/nodeid.prom

set -- /bin/node_exporter "$@"

exec "$@"
