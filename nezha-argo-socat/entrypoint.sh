#!/bin/sh

# 启动 socat
echo "Starting socat..."
socat TCP-LISTEN:8080,fork TCP:localhost:8008 &
sleep 3

# 启动 dashboard app
echo "Starting dashboard app..."
/dashboard/app &
sleep 3

# 等待所有后台进程
wait
