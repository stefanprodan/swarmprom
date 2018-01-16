#!/bin/bash -eu

# rebuild images with updated version of source images and upload them in the local registry

REGISTRY='myregistry.local:5100'

cd node-exporter
NAME=$REGISTRY/swarmprom-node-exporter:0.15.2
docker build -t $NAME .
docker push $NAME
cd ..

# Verify that images are all there
curl -kL https://$REGISTRY/v2/_catalog

