FROM prom/prometheus:v1.7.1

ENV WEAVE_TOKEN=none

COPY prometheus /etc/prometheus/
RUN chmod +x /etc/prometheus/docker-entrypoint.sh

ENTRYPOINT [ "/etc/prometheus/docker-entrypoint.sh" ]
CMD        [ "-config.file=/etc/prometheus/prometheus.yml", \
             "-storage.local.path=/prometheus", \
             "-web.console.libraries=/etc/prometheus/console_libraries", \
             "-web.console.templates=/etc/prometheus/consoles" ]
