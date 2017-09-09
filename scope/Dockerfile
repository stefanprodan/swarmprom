FROM alpine:3.6

ENV WEAVESCOPE_DOCKER_ARGS='--restart unless-stopped'

RUN apk add --update curl bash \
  && rm -rf /var/cache/apk/* \
  && curl -L https://download.docker.com/linux/static/stable/x86_64/docker-17.06.2-ce.tgz -o docker.tgz \
  && tar -xvzf docker.tgz \
  && mv docker/docker /usr/local/bin/docker \
  && chmod +x /usr/local/bin/docker \
  && rm -rf docker docker.tgz \
  && chmod +x /usr/local/bin/docker \
  && curl -L git.io/scope -o /usr/local/bin/scope \
  && chmod +x /usr/local/bin/scope \
  && docker -v
