FROM prom/prometheus:v2.0.0
# https://hub.docker.com/r/prom/prometheus/tags/
# docker build -t myregistry.local:5100/swarmprom-prometheus:2.0.0 .

ENV WEAVE_TOKEN=none

COPY conf /etc/prometheus/

ENTRYPOINT [ "/etc/prometheus/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/etc/prometheus/console_libraries", \
             "--web.console.templates=/etc/prometheus/consoles" ]
