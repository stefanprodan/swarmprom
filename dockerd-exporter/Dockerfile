FROM alpine:latest

RUN apk add --no-cache socat

ENV IN="172.18.0.1:9323" \
    OUT="9323"

ENTRYPOINT socat -d -d TCP-L:$OUT,fork TCP:$IN
