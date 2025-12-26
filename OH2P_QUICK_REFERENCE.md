# OH2P 平台快速参考

## 一句话说明
OH2P 是专为智能音箱设计的音频专用串流平台，只处理音频，不处理视频。

## 快速开始（3步）

```bash
# 1. 配对
./moonlight pair -keydir=/tmp/moonlight/certs 10.0.0.14

# 2. 串流
./moonlight stream -platform oh2p -audio dmixer -app "Desktop" 10.0.0.14

# 3. 退出
按 Ctrl+Alt+Shift+Q
```

## 常用命令

### 基本串流
```bash
./moonlight stream -platform oh2p -audio dmixer -app "Desktop" <IP>
```

### 使用配置文件
```bash
./moonlight stream -config oh2p-example.conf
```

### 快速入门脚本
```bash
./oh2p-quickstart.sh
```

### 查看可用应用
```bash
./moonlight list <IP>
```

## 常用参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `-platform oh2p` | 指定平台（必需） | `-platform oh2p` |
| `-audio <device>` | ALSA设备 | `-audio dmixer` |
| `-app <name>` | 应用名称 | `-app "Desktop"` |
| `-keydir <path>` | 证书目录 | `-keydir=/tmp/certs` |
| `-bitrate <kbps>` | 比特率 | `-bitrate 5000` |
| `-surround <5.1\|7.1>` | 环绕声 | `-surround 5.1` |
| `-verbose` | 详细输出 | `-verbose` |
| `-viewonly` | 仅查看 | `-viewonly` |

## ALSA 设备

### 查看设备
```bash
aplay -L
```

### 常用设备
- `default` - 系统默认
- `dmixer` - 软件混音
- `hw:0,0` - 硬件设备
- `plughw:0,0` - 带转换

### 测试设备
```bash
speaker-test -D dmixer -c 2
```

## 配置文件示例

```ini
platform = oh2p
audio = dmixer
app = Desktop
address = 10.0.0.14
keydir = /tmp/moonlight/certs
bitrate = 5000
fps = 30
```

## 故障排查

### 音频无输出
```bash
# 1. 检查设备
aplay -L

# 2. 测试设备
speaker-test -D dmixer -c 2

# 3. 尝试其他设备
./moonlight stream -platform oh2p -audio default ...
```

### 连接失败
```bash
# 1. 重新配对
./moonlight pair <IP>

# 2. 检查网络
ping <IP>

# 3. 检查证书
ls -la /tmp/moonlight/certs/
```

### 音频延迟
```bash
# 降低比特率
./moonlight stream -platform oh2p -bitrate 3000 ...
```

## 性能优化

### 低端设备
```bash
./moonlight stream -platform oh2p -audio dmixer -bitrate 3000 -fps 30 <IP>
```

### 高质量
```bash
./moonlight stream -platform oh2p -audio hw:0,0 -bitrate 10000 -surround 5.1 <IP>
```

### 后台运行
```bash
nohup ./moonlight stream -platform oh2p -audio default -app "Desktop" <IP> &
```

## 应用场景

| 场景 | 命令 |
|------|------|
| 音乐播放 | `-app "Spotify"` |
| 桌面音频 | `-app "Desktop"` |
| 游戏音频 | `-app "Game Name"` |
| 仅监听 | `-viewonly` |

## 编译

```bash
mkdir build && cd build
cmake -DHAVE_ALSA=ON ..
make
```

## 文档

- **详细文档**: OH2P_PLATFORM.md
- **实现说明**: OH2P_README.md
- **修改总结**: OH2P_CHANGES_SUMMARY.md

## 测试

```bash
./test-oh2p-platform.sh
```

## 帮助

```bash
./moonlight help
```

---

**提示**: 首次使用请运行 `./oh2p-quickstart.sh` 获得交互式引导！
