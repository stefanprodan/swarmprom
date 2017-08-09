FROM prom/alertmanager:v0.8.0

COPY conf /etc/alertmanager/

ENTRYPOINT  [ "/etc/alertmanager/docker-entrypoint.sh" ]
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "-config.file=/etc/alertmanager/alertmanager.yml", \
             "-storage.path=/alertmanager" ]
