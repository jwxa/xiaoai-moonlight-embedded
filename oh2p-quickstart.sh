#!/bin/bash
# OH2P 音频专用平台快速入门脚本

set -e

echo "=========================================="
echo "OH2P 音频专用平台快速入门"
echo "=========================================="
echo ""

# 检查moonlight可执行文件
if [ ! -f "./moonlight" ]; then
    echo "错误: 找不到 moonlight 可执行文件"
    echo "请先编译项目: mkdir build && cd build && cmake .. && make"
    exit 1
fi

# 检查ALSA
if ! command -v aplay &> /dev/null; then
    echo "警告: 未找到 aplay 命令，ALSA可能未安装"
    echo "请安装ALSA: sudo apt-get install alsa-utils libasound2-dev"
fi

# 获取服务器地址
read -p "请输入串流服务器IP地址 (例如: 10.0.0.14): " SERVER_IP
if [ -z "$SERVER_IP" ]; then
    echo "错误: 服务器地址不能为空"
    exit 1
fi

# 获取音频设备
echo ""
echo "可用的ALSA设备:"
aplay -L 2>/dev/null | grep -E "^(default|sysdefault|dmixer|hw:|plughw:)" | head -10 || echo "  default"
echo ""
read -p "请输入ALSA音频设备 (默认: dmixer): " AUDIO_DEVICE
AUDIO_DEVICE=${AUDIO_DEVICE:-dmixer}

# 获取应用名称
read -p "请输入要串流的应用名称 (默认: Desktop): " APP_NAME
APP_NAME=${APP_NAME:-Desktop}

# 证书目录
CERT_DIR="/tmp/moonlight/certs"
mkdir -p "$CERT_DIR"

echo ""
echo "=========================================="
echo "配置信息:"
echo "  服务器地址: $SERVER_IP"
echo "  音频设备: $AUDIO_DEVICE"
echo "  应用名称: $APP_NAME"
echo "  证书目录: $CERT_DIR"
echo "=========================================="
echo ""

# 检查是否已配对
if [ ! -f "$CERT_DIR/client.pem" ]; then
    echo "首次使用，需要先配对设备..."
    echo ""
    ./moonlight pair -keydir="$CERT_DIR" "$SERVER_IP"
    echo ""
    if [ $? -ne 0 ]; then
        echo "配对失败，请检查服务器地址和网络连接"
        exit 1
    fi
    echo "配对成功！"
    echo ""
fi

# 测试音频设备
echo "测试音频设备..."
if speaker-test -D "$AUDIO_DEVICE" -c 2 -t sine -f 440 -l 1 &> /dev/null; then
    echo "音频设备测试成功"
else
    echo "警告: 音频设备测试失败，但仍会尝试连接"
fi
echo ""

# 列出可用应用
echo "获取可用应用列表..."
./moonlight list -keydir="$CERT_DIR" "$SERVER_IP"
echo ""

# 开始串流
echo "=========================================="
echo "开始音频串流..."
echo "按 Ctrl+Alt+Shift+Q 退出"
echo "=========================================="
echo ""

./moonlight stream \
    -platform oh2p \
    -audio "$AUDIO_DEVICE" \
    -keydir="$CERT_DIR" \
    -app "$APP_NAME" \
    -verbose \
    "$SERVER_IP"

echo ""
echo "串流已结束"
