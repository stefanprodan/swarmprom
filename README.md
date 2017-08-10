# swarmprom

Docker Swarm instrumentation with 
Prometheus, node-exporter, dockerd-exporter, cAdvisor, alertmanager and Grafana

### Install

Clone this repository and run the monitoring stack:

```bash
$ git clone https://github.com/stefanprodan/swarmprom.git
$ cd swarmprom

SLACK_URL=https://hooks.slack.com/services/TOKEN \
SLACK_CHANNEL=devops-alerts \
SLACK_USER=alertmanager \
docker stack deploy -c docker-compose.yml sp
```

Run the stack with Weave Cloud remote write:

```bash
TOKEN=<WEAVE-TOKEN> docker stack deploy -c weave-compose.yml sw
``` 

