FROM ghcr.io/nezhahq/nezha AS builder
RUN apk add --no-cache \
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
COPY --from=builder /dashboard/app /dashboard/app
RUN mkdir -p /dashboard/data && chmod -R 777 /dashboard
ENV HTTP_PORT=8008 GRPC_PORT=8080
EXPOSE $HTTP_PORT $GRPC_PORT
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
