FROM golang

RUN go get github.com/gilbertchen/duplicacy/duplicacy
RUN go build -v github.com/gilbertchen/duplicacy/duplicacy

# Real container
FROM debian:buster-slim
USER root

RUN set -eux && \
  apt-get update && \
  apt-get install -y ca-certificates --no-install-recommends

RUN mkdir -p /usr/local/bin
COPY --from=0 /go/bin/duplicacy /usr/local/bin

COPY bin/* /usr/local/bin/

RUN chmod 755 /usr/local/bin/*

# Where to copy from
VOLUME /data

ENTRYPOINT ["docker-entrypoint"]
