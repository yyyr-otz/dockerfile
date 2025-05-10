FROM ghcr.io/nezhahq/nezha AS app
FROM alpine:latest
RUN apk update && apk upgrade && \
    apk --no-cache add \
    aws-cli \
    tar \
    gzip \
    tzdata \
    openssl \
    sqlite \
    coreutils \
    socat
ENV TZ=Asia/Shanghai
WORKDIR /dashboard
COPY --from=app /dashboard/app /dashboard/app
RUN mkdir -p /dashboard/data && chmod -R 777 /dashboard
ENV HTTP_PORT=8008 GRPC_PORT=8080
EXPOSE $HTTP_PORT $GRPC_PORT
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
