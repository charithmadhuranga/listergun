# Build Stage
FROM golang:1.14 AS build-stage

LABEL app="build-listergun"
LABEL REPO="https://github.com/werbot/listergun"

ENV PROJPATH=/go/src/github.com/werbot/listergun

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/werbot/listergun
WORKDIR /go/src/github.com/werbot/listergun

RUN make build-alpine

# Final Stage
FROM alpine:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/werbot/listergun"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/listergun/bin

WORKDIR /opt/listergun/bin

COPY --from=build-stage /go/src/github.com/werbot/listergun/bin/listergun /opt/listergun/bin/
RUN chmod +x /opt/listergun/bin/listergun

# Create appuser
RUN adduser -D -g '' listergun
USER listergun

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/listergun/bin/listergun"]
