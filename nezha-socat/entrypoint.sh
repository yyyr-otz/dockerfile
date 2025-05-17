#!/bin/sh
export STDLOG={STDLOG:=true}
export HTTP_PORT={HTTP_PORT:=8008}
export GRPC_PORT={GRPC_PORT:=8080}
export TARGET_PORT={TARGET_PORT:=8008}

#[ "$STDLOG" = "true" ] && LOG_OUTPUT="/dev/stdout" LOG_ERRPUT="/dev/stderr" || LOG_OUTPUT="/dev/null" LOG_ERRPUT="/dev/null"

if [ "$STDLOG" = "true" ]; then
    LOG_OUTPUT="/dev/stdout"
    LOG_ERRPUT="/dev/stderr"
else
    LOG_OUTPUT="/dev/null"
    LOG_ERRPUT="/dev/null"
fi

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
[supervisord]
nodaemon=true
logfile=/dev/null
pidfile=/run/supervisord.pid

[program:nezha]
command=/dashboard/app -c /dashboard/data/config.yaml -db /dashboard/data//sqlite.db
autorestart=true
stdout_logfile=$LOG_OUTPUT
stdout_logfile_maxbytes=0
stderr_logfile=$LOG_ERRPUT
stderr_logfile_maxbytes=0

[program:socat-grpc]
command=socat TCP-LISTEN:$GRPC_PORT,fork,reuseaddr TCP:localhost:$TARGET_PORT
autorestart=true
stdout_logfile=$LOG_OUTPUT
stdout_logfile_maxbytes=0
stderr_logfile=$LOG_ERRPUT
stderr_logfile_maxbytes=0
EOF

if [ "$HTTP_PORT" != "$TARGET_PORT" ]; then
  cat >> /etc/supervisor/conf.d/damon.conf << EOF
[program:socat-http]
command=socat TCP-LISTEN:$HTTP_PORT,fork,reuseaddr TCP:localhost:$TARGET_PORT
autorestart=true
stdout_logfile=$LOG_OUTPUT
stdout_logfile_maxbytes=0
stderr_logfile=$LOG_ERRPUT
stderr_logfile_maxbytes=0
EOF
fi

exec supervisord -c /etc/supervisor/supervisord.conf
