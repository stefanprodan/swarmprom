FROM grafana/grafana:4.6.3
# https://hub.docker.com/r/grafana/grafana/tags/
# docker build -t myregistry.local:5100/swarmprom-grafana:4.6.3 .

COPY docker-entrypoint.sh /etc/grafana/docker-entrypoint.sh
COPY datasources /etc/grafana/datasources/
COPY dashboards /etc/grafana/dashboards/

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin

ENTRYPOINT ["/etc/grafana/docker-entrypoint.sh"]
