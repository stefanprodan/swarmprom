#!/bin/bash -e

cat /etc/prometheus/prometheus.yml > /tmp/prometheus.yml
cat /etc/prometheus/weave-cortex.yml | \
    sed "s@#password: <token>#@password: '$WEAVE_TOKEN'@g" > /tmp/weave-cortex.yml

# JOBS=mongo-exporter:9111,redis-exporter:9112

if [ ${JOBS+x} ]; then
IFS=,
ary=($JOBS)
for key in "${!ary[@]}"; do
echo "adding job ${ary[$key]}"

SERVICE="$(cut -d':' -f1 <<<"${ary[$key]}")"
PORT="$(cut -d':' -f2 <<<"${ary[$key]}")"

cat >>/tmp/prometheus.yml <<EOF
  - job_name: '${SERVICE}'
    dns_sd_configs:
    - names:
      - 'tasks.${SERVICE}'
      type: 'A'
      port: ${PORT}

EOF

cat >>/tmp/weave-cortex.yml <<EOF
  - job_name: '${SERVICE}'
    dns_sd_configs:
    - names:
      - 'tasks.${SERVICE}'
      type: 'A'
      port: ${PORT}

EOF

done
fi

mv /tmp/prometheus.yml /etc/prometheus/prometheus.yml
mv /tmp/weave-cortex.yml /etc/prometheus/weave-cortex.yml

set -- /bin/prometheus "$@"

exec "$@"

