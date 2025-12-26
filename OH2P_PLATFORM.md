# OH2P 音频专用平台

## 概述

OH2P 是一个专为智能音箱设计的音频专用串流平台。该平台只处理音频流，不进行视频渲染，适用于ARM32位设备。

## 特性

- **纯音频串流**：不处理视频数据，降低CPU和内存占用
- **ALSA音频输出**：使用ALSA作为音频后端，支持指定播放设备
- **低资源占用**：适合智能音箱等嵌入式设备
- **ARM32位支持**：针对ARM架构优化

## 使用方法

### 基本命令

```bash
./moonlight stream -platform oh2p -audio dmixer -keydir=/tmp/moonlight/certs -app "Desktop" "10.0.0.14"
```

### 参数说明

- `-platform oh2p`: 指定使用OH2P音频专用平台
- `-audio <device>`: 指定ALSA音频设备（如 `dmixer`, `default`, `hw:0,0` 等）
- `-keydir <path>`: 证书存储目录
- `-app <name>`: 要串流的应用名称
- 最后的IP地址: 串流服务器地址

### 音频设备示例

```bash
# 使用默认设备
./moonlight stream -platform oh2p -app "Desktop" "10.0.0.14"

# 使用dmixer设备
./moonlight stream -platform oh2p -audio dmixer -app "Desktop" "10.0.0.14"

# 使用硬件设备
./moonlight stream -platform oh2p -audio hw:0,0 -app "Desktop" "10.0.0.14"

# 使用plughw设备（带格式转换）
./moonlight stream -platform oh2p -audio plughw:0,0 -app "Desktop" "10.0.0.14"
```

### 配置文件示例

创建配置文件 `oh2p.conf`:

```ini
platform = oh2p
audio = dmixer
app = Desktop
address = 10.0.0.14
keydir = /tmp/moonlight/certs
bitrate = 5000
fps = 30
```

使用配置文件：

```bash
./moonlight stream -config oh2p.conf
```

## 编译要求

确保编译时启用了ALSA支持：

```bash
cmake -DHAVE_ALSA=ON ..
make
```

## 技术细节

### 平台特性

- **视频回调**: 返回 NULL（不处理视频）
- **音频回调**: 使用 ALSA 音频渲染器
- **输入处理**: 支持标准输入设备（如需要）

### ALSA设备选择

OH2P平台会将 `-audio` 参数传递给ALSA，如果未指定，默认使用 `sysdefault` 设备。

常用ALSA设备：
- `default`: 系统默认设备
- `sysdefault`: 系统默认设备（推荐）
- `dmixer`: ALSA dmix插件（软件混音）
- `hw:X,Y`: 硬件设备（X=卡号，Y=设备号）
- `plughw:X,Y`: 带格式转换的硬件设备

### 查看可用ALSA设备

```bash
# 列出所有PCM设备
aplay -L

# 列出声卡
aplay -l
```

## 故障排查

### 音频无输出

1. 检查ALSA设备是否正确：
   ```bash
   aplay -L
   ```

2. 测试ALSA设备：
   ```bash
   speaker-test -D dmixer -c 2
   ```

3. 检查音量设置：
   ```bash
   alsamixer
   ```

### 连接失败

1. 确保已配对：
   ```bash
   ./moonlight pair 10.0.0.14
   ```

2. 检查证书目录权限：
   ```bash
   mkdir -p /tmp/moonlight/certs
   chmod 755 /tmp/moonlight/certs
   ```

### 性能问题

1. 降低比特率：
   ```bash
   ./moonlight stream -platform oh2p -bitrate 3000 ...
   ```

2. 降低帧率（虽然不处理视频，但会影响音频同步）：
   ```bash
   ./moonlight stream -platform oh2p -fps 30 ...
   ```

## 与其他平台的区别

| 平台 | 视频 | 音频 | 适用场景 |
|------|------|------|----------|
| oh2p | ✗ | ✓ (ALSA) | 智能音箱、音频设备 |
| fake | ✗ | ✗ | 测试、无输出 |
| pi | ✓ | ✓ | 树莓派 |
| sdl | ✓ | ✓ | 通用桌面 |

## 示例场景

### 智能音箱音乐串流

```bash
# 串流音乐播放器
./moonlight stream -platform oh2p -audio dmixer -app "Spotify" "192.168.1.100"
```

### 后台音频服务

```bash
# 作为系统服务运行
./moonlight stream -platform oh2p -audio default -viewonly -app "Desktop" "192.168.1.100" &
```

### 多房间音频

```bash
# 房间1
./moonlight stream -platform oh2p -audio hw:0,0 -app "Desktop" "192.168.1.100" &

# 房间2
./moonlight stream -platform oh2p -audio hw:1,0 -app "Desktop" "192.168.1.100" &
```
