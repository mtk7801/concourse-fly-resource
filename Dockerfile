FROM alpine:edge

COPY assets/* /opt/resource/

RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      jq; \
    update-ca-certificates
