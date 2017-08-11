#!/bin/sh -e

NODE_NAME=$(cat /etc/nodename)
echo "node_id{node_id=\"$NODE_ID\", node_name=\"$NODE_NAME\"} 1" > /etc/node-exporter/node-meta.prom

set -- /bin/node_exporter "$@"

exec "$@"
