FROM debian:buster-slim
USER root

# Setup
RUN apt-get update
RUN apt-get install -y ca-certificates wget --no-install-recommends
RUN mkdir -p /usr/local/bin && mkdir -p /build

ARG DUPLICACY_VERSION
ARG DUPLICACY_UTIL_VERSION

ENV DUPLICACY_VERSION ${DUPLICACY_VERSION:-2.2.3}
ENV DUPLICACY_UTIL_VERSION ${DUPLICACY_UTIL_VERSION:-1.5}

COPY scripts/* /usr/local/bin/

RUN download-from-github

# Real container
FROM debian:buster-slim
USER root

RUN apt-get update && \
  apt-get install -y ca-certificates --no-install-recommends

RUN mkdir -p /usr/local/bin
COPY --from=0 /usr/local/bin/duplicacy* /usr/local/bin/

COPY bin/* /usr/local/bin/

RUN chmod 755 /usr/local/bin/*

# Where to copy from
VOLUME /data

ENTRYPOINT ["docker-entrypoint"]
