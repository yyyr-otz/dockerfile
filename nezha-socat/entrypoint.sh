#!/bin/sh
: ${STDLOG:=true}
: ${HTTP_PORT:=8008}
: ${GRPC_PORT:=8080}
: ${TARGET_PORT:=8008}

[ "$STDLOG" = "true" ] && LOG_OUTPUT="/dev/stdout" LOG_ERRPUT="/dev/stderr" || LOG_OUTPUT="/dev/null" LOG_ERRPUT="/dev/null"

mkdir -p /etc/supervisor/conf.d

cat > /etc/supervisor/conf.d/damon.conf << EOF
[supervisord]
nodaemon=true
logfile=/dev/null
pidfile=/run/supervisord.pid

[program:nezha]
command=/dashboard/app
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
