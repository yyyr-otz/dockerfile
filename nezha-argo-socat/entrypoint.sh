#!/bin/sh
# 默认值（如果未设置环境变量）
HTTP_PORT=${HTTP_PORT:-8008}
GRPC_PORT=${GRPC_PORT:-8080}
TARGET_PORT=8008  # 固定转发目标
# 启动 socat
echo "Starting socat..."
# 1. 强制转发 GRPC_PORT → 8008
echo "Forwarding GRPC_PORT ($GRPC_PORT) to $TARGET_PORT"
socat TCP-LISTEN:$GRPC_PORT,fork,reuseaddr TCP:localhost:$TARGET_PORT &
# 2. 如果 HTTP_PORT 不是 8008，则额外转发 HTTP_PORT → 8008
if [ "$HTTP_PORT" != "$TARGET_PORT" ]; then
    echo "Forwarding HTTP_PORT ($HTTP_PORT) to $TARGET_PORT"
    socat TCP-LISTEN:$HTTP_PORT,fork,reuseaddr TCP:localhost:$TARGET_PORT &
fi
sleep 3

# 启动 dashboard app
echo "Starting dashboard app..."
/dashboard/app &
sleep 3

# 等待所有后台进程
wait
