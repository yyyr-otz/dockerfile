#!/bin/sh
HTTP_PORT=${HTTP_PORT:-8008}
GRPC_PORT=${GRPC_PORT:-8080}
TARGET_PORT=8008

# 生成默认的supervisord.conf（如果不存在）
mkdir -p /etc/supervisor/conf.d
if [ ! -f /etc/supervisor/supervisord.conf ]; then
  cat > /etc/supervisor/supervisord.conf << EOF
[supervisord]
nodaemon=true
[include]
files = /etc/supervisor/conf.d/*.conf
EOF
fi

cat > /etc/supervisor/conf.d/damon.conf << EOF
[program:nezha]
command=/dashboard/app
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:socat-grpc]
command=socat TCP-LISTEN:$GRPC_PORT,fork,reuseaddr TCP:localhost:$TARGET_PORT
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

if [ "$HTTP_PORT" != "$TARGET_PORT" ]; then
  cat >> /etc/supervisor/conf.d/damon.conf << EOF
[program:socat-http]
command=socat TCP-LISTEN:$HTTP_PORT,fork,reuseaddr TCP:localhost:$TARGET_PORT
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF
fi

exec supervisord -c /etc/supervisor/supervisord.conf
