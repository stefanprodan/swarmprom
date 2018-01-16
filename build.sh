#!/bin/bash -eu

# rebuild images with updated version of source images and upload them in the local registry

REGISTRY='myregistry.local:5100'

cd alertmanager
NAME=$REGISTRY/swarmprom-alertmanager:0.13.0
docker build -t $NAME .
docker push $NAME
cd ..

cd grafana
NAME=$REGISTRY/swarmprom-grafana:4.6.3
docker build -t $NAME .
docker push $NAME
cd ..

cd prometheus
NAME=$REGISTRY/swarmprom-prometheus:2.0.0
docker build -t $NAME .
docker push $NAME
cd ..

# Verify that images are all there
curl -kL https://$REGISTRY/v2/_catalog

