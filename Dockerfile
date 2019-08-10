FROM golang

RUN go get github.com/gilbertchen/duplicacy/duplicacy

RUN go get github.com/djherbis/times
RUN go get github.com/mitchellh/go-homedir
RUN go get github.com/spf13/viper
RUN go get github.com/theckman/go-flock
RUN go get gopkg.in/gomail.v2
RUN cd src && git clone https://github.com/jeffaco/duplicacy-util.git

# COPY tmp/src /go/
RUN go build -v github.com/gilbertchen/duplicacy/duplicacy
RUN cd src/duplicacy-util && go build

# Real container
# FROM debian:buster-slim
FROM alpine:3.9
USER root

RUN mkdir -p /usr/local/bin
COPY --from=0 /go/bin/duplicacy /usr/local/bin
COPY --from=0 /go/src/duplicacy-util/duplicacy-util /usr/local/bin
COPY bin/* /usr/local/bin/

RUN chmod 755 /usr/local/bin/*

# Where to copy from
VOLUME /data

ENTRYPOINT ["docker-entrypoint"]
