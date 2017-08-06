# prometheus-swarm

Docker Swarm instrumentation with Prometheus

Run stack with standalone Prometheus, dockerd-exporter, cAdvisor and Grafana:

```bash
docker stack deploy -c docker-compose.yml mon
```

Run stack with Weave Cloud remote write:

```bash
TOKEN=<WEAVE-TOKEN> docker stack deploy -c weave-compose.yml weave
``` 

