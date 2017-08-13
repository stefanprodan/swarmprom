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

Services:

* prometheus (metrics database) `http://<swarm-ip>:9090`
* grafana (visualize metrics) `http://<swarm-ip>:3000`
* node-exporter (host metrics collector)
* cadvisor (containers metrics collector)
* dockerd-exporter (Docker daemon metrics collector)
* alertmanager (alerts dispatcher) `http://<swarm-ip>:9093`

### Prometheus service discovery 

In order to collect metrics from Swarm nodes you need to deploy the exporters on each server. 
Using global services you don't have to manually deploy the exporters. When you scale up your 
cluster, Swarm will lunch a cAdvisor, node-exporter and dockerd-exporter instance on the newly created nodes. Using global services you don't have to manually 
All you need is an automated way for Prometheus to reach these instances.

Running Prometheus on the same overlay network as the exporter services allows you to use the DNS service 
discovery. Knowing the exporters service name you can configure DNS discovery like so:

```yaml
scrape_configs:
  - job_name: 'node-exporter'
    dns_sd_configs:
    - names:
      - 'tasks.node-exporter'
      type: 'A'
      port: 9100
  - job_name: 'cadvisor'
    dns_sd_configs:
    - names:
      - 'tasks.cadvisor'
      type: 'A'
      port: 8080
  - job_name: 'dockerd-exporter'
    dns_sd_configs:
    - names:
      - 'tasks.dockerd-exporter'
      type: 'A'
      port: 9323
``` 

When Prometheus runs the DNS lookup, the Docker Swarm will return a list of IPs for each task. 
Using these IPs Prometheus will bypass the Swarm load balancer and will be able to scrape each exporter 
instance. 

The problem with this approach is that you'll not be able to tell which exporter runs on which node. 
Your Swarm nodes real IPs are different form the exporters IPs since exporters IPs are dynamically 
assigned by Docker and are part of the overlay network. 
Swarm doesn't provide any records for the tasks DNS besides the overlay IP. 
If Swarm would provide SRV records with the nodes hostname or IP you would be able to relabel the source 
and overwrite the overlay IP with the real IP. 

In order to tell which host a node-exporter instance is running, I had to create a prom file inside 
the node-exporter containing the hostname and the Docker Swarm node ID. 

When a node-exporter container starts `node-meta.prom` is generated with the following content:

```bash
"node_meta{node_id=\"$NODE_ID\", node_name=\"$NODE_NAME\"} 1"
```

The node ID value is supplied via `{{.Node.ID}}` and the node name is extracted from the `/etc/hostname` 
file that's mounted inside the node-exporter container.

```yaml
  node-exporter:
    image: stefanprodan/swarmprom-node-exporter
    environment:
      - NODE_ID={{.Node.ID}}
    volumes:
      - /etc/hostname:/etc/nodename
    command:
      - '-collector.textfile.directory=/etc/node-exporter/'
```

Using the textfile command you can instruct node-exporter to collect the `node_meta` metric. 
Now that you have a metric containing Docker Swarm node ID and name you can use it in promql queries. 

Let's say you want to find the available memory on each node, normally you would write something like this:

```
sum(node_memory_MemAvailable) by (instance)

{instance="10.0.0.5:9100"} 889450496
{instance="10.0.0.13:9100"} 1404162048
{instance="10.0.0.15:9100"} 1406574592
```

The above result is not very helpful since you can't tell what Swarm node is behind the instance IP. 
Let's write that query taking in account the node_meta metric:

```sql
sum(node_memory_MemAvailable * on(instance) group_left(node_name) node_meta) by (node_name)

{node_name="swarm-manager-1"} 889450496
{node_name="swarm-worker-1"} 1404162048
{node_name="swarm-worker-2"} 1406574592
``` 

This is much better, instead of overlay IPs now I can see the actual Docker Swarm nodes hostname.

### Setup Grafana

Navigate to `http://<swarm-ip>:3000` and login with user ***admin*** password ***admin***. 
You can change the credentials in the compose file.

From the Grafana menu, choose ***Data Sources*** and click on ***Add Data Source***. 
Use the following values to add the Prometheus service as data source:

* Name: Prometheus
* Type: Prometheus
* Url: http://prometheus:9090
* Access: proxy

If you are using Weave Cloud:

* Name: Prometheus
* Type: Prometheus
* Url: https://cloud.weave.works/api/prom
* Access: proxy
* Basic auth: use your service token as password, the user value is ignored

Now you can import the dashboard temples from the [grafana](https://github.com/stefanprodan/swarmprom/tree/master/grafana) directory. 
From the Grafana menu, choose ***Dashboards*** and click on ***Import***.

***Docker Swarm Nodes Dashboard***

![Nodes](https://raw.githubusercontent.com/stefanprodan/swarmprom/master/grafana/swarmprom-nodes-dash-v1.png)


This dashboard shows key metrics for monitoring the resource usage of your Swarm nodes and can be filtered by node ID:

* Cluster uptime, number of nodes, number of CPUs, CPU idle gauge
* System load average graph, CPU usage graph by node
* Total memory, available memory gouge, total disk space and available storage gouge
* Memory usage graph by node (used and cached)
* I/O usage graph (read and write Bps)
* IOPS usage (read and write operation per second) and CPU IOWait
* Running containers graph by Swarm service and node
* Network usage graph (inbound Bps, outbound Bps)
* Nodes list (instance, node ID, node name)

***Docker Swarm Services Dashboard***

![Nodes](https://raw.githubusercontent.com/stefanprodan/swarmprom/master/grafana/swarmprom-services-dash-v1.png)

This dashboard shows key metrics for monitoring the resource usage of your Swarm stacks and services, can be filtered by node ID:

* Number of nodes, stacks, services and running container
* Swarm tasks graph by service name
* Health check graph (total health checks and failed checks)
* CPU usage graph by service and by container (top 10)
* Memory usage graph by service and by container (top 10)
* Network usage graph by service (received and transmitted)
* Cluster network traffic and IOPS graphs
* Docker engine container and network actions by node
* Docker engine list (version, node id, OS, kernel, graph driver)
