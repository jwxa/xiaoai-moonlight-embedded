# OH2P 音频专用平台实现说明

## 概述

本次修改为 Moonlight Embedded 添加了 OH2P 平台支持，这是一个专为智能音箱设计的音频专用串流平台。

## 修改内容

### 1. 核心代码修改

#### src/platform.h
- 在 `enum platform` 中添加了 `OH2P` 枚举值

#### src/platform.c
- 在 `platform_check()` 函数中添加了 oh2p 平台检测逻辑
- 在 `platform_get_video()` 函数中为 OH2P 返回 NULL（不处理视频）
- 在 `platform_get_audio()` 函数中为 OH2P 返回 ALSA 音频回调
- 在 `platform_name()` 函数中添加了 OH2P 平台名称

#### src/main.c
- 更新了帮助信息，在 `-platform` 参数说明中添加了 oh2p 选项

### 2. 文档和示例文件

- **OH2P_PLATFORM.md**: 详细的平台使用文档
- **oh2p-example.conf**: 配置文件示例
- **oh2p-quickstart.sh**: 快速入门脚本
- **OH2P_README.md**: 本文件，实现说明

## 技术特性

### 平台特点

1. **纯音频串流**: 不处理视频数据，降低资源占用
2. **ALSA后端**: 使用 ALSA 作为音频输出，支持各种 ALSA 设备
3. **嵌入式优化**: 作为嵌入式平台处理，支持 evdev 输入
4. **ARM32位支持**: 适用于 ARM 架构的智能音箱

### 工作原理

```
串流服务器 → 网络 → Moonlight Client (OH2P)
                              ↓
                         音频解码 (Opus)
                              ↓
                         ALSA 输出
                              ↓
                         音频设备
```

### 与其他平台的对比

| 功能 | OH2P | FAKE | PI | SDL |
|------|------|------|----|----|
| 视频渲染 | ✗ | ✗ | ✓ | ✓ |
| 音频输出 | ✓ (ALSA) | ✗ | ✓ | ✓ |
| 输入处理 | ✓ (evdev) | ✗ | ✓ | ✓ |
| 资源占用 | 低 | 最低 | 中 | 中 |
| 适用场景 | 音频设备 | 测试 | 树莓派 | 桌面 |

## 使用方法

### 快速开始

1. **编译项目**（确保启用 ALSA 支持）:
   ```bash
   mkdir build && cd build
   cmake -DHAVE_ALSA=ON ..
   make
   ```

2. **配对设备**:
   ```bash
   ./moonlight pair -keydir=/tmp/moonlight/certs 10.0.0.14
   ```

3. **开始串流**:
   ```bash
   ./moonlight stream -platform oh2p -audio dmixer -keydir=/tmp/moonlight/certs -app "Desktop" 10.0.0.14
   ```

### 使用快速入门脚本

```bash
chmod +x oh2p-quickstart.sh
./oh2p-quickstart.sh
```

### 使用配置文件

```bash
# 编辑配置文件
cp oh2p-example.conf my-oh2p.conf
nano my-oh2p.conf

# 使用配置文件启动
./moonlight stream -config my-oh2p.conf
```

## 命令行参数

### 必需参数

- `-platform oh2p`: 指定使用 OH2P 平台
- `<server_ip>`: 串流服务器 IP 地址

### 可选参数

- `-audio <device>`: ALSA 音频设备（默认: sysdefault）
- `-app <name>`: 应用名称（默认: Steam）
- `-keydir <path>`: 证书目录
- `-bitrate <kbps>`: 音频比特率
- `-fps <fps>`: 帧率（影响音频同步）
- `-surround <5.1|7.1>`: 环绕声配置
- `-localaudio`: 在服务器端也播放音频
- `-viewonly`: 仅查看模式（禁用输入）
- `-verbose`: 详细输出
- `-debug`: 调试输出

## ALSA 设备配置

### 查看可用设备

```bash
# 列出所有 PCM 设备
aplay -L

# 列出声卡
aplay -l
```

### 常用设备

- `default`: 系统默认设备
- `sysdefault`: 系统默认设备（推荐）
- `dmixer`: ALSA dmix 插件（软件混音）
- `hw:0,0`: 硬件设备（卡0，设备0）
- `plughw:0,0`: 带格式转换的硬件设备

### 测试设备

```bash
# 测试音频设备
speaker-test -D dmixer -c 2

# 播放测试文件
aplay -D dmixer test.wav
```

## 编译要求

### 必需依赖

- ALSA 开发库: `libasound2-dev`
- Opus 编解码器: `libopus-dev`
- OpenSSL: `libssl-dev`
- 其他标准依赖

### 编译选项

```bash
cmake \
  -DHAVE_ALSA=ON \
  -DCMAKE_BUILD_TYPE=Release \
  ..
```

## 故障排查

### 问题: 音频无输出

**解决方案**:
1. 检查 ALSA 设备: `aplay -L`
2. 测试设备: `speaker-test -D dmixer -c 2`
3. 检查音量: `alsamixer`
4. 尝试其他设备: `-audio default` 或 `-audio plughw:0,0`

### 问题: 连接失败

**解决方案**:
1. 确保已配对: `./moonlight pair <server_ip>`
2. 检查网络连接: `ping <server_ip>`
3. 检查防火墙设置
4. 验证证书目录权限

### 问题: 音频延迟

**解决方案**:
1. 降低比特率: `-bitrate 3000`
2. 使用硬件设备: `-audio hw:0,0`
3. 优化网络连接
4. 检查 CPU 负载

### 问题: 音频卡顿

**解决方案**:
1. 检查网络稳定性
2. 降低比特率
3. 使用有线网络
4. 关闭其他占用带宽的应用

## 性能优化建议

### 低端设备

```bash
./moonlight stream \
  -platform oh2p \
  -audio dmixer \
  -bitrate 3000 \
  -fps 30 \
  -viewonly \
  <server_ip>
```

### 高质量音频

```bash
./moonlight stream \
  -platform oh2p \
  -audio hw:0,0 \
  -bitrate 10000 \
  -surround 5.1 \
  <server_ip>
```

### 后台服务

```bash
nohup ./moonlight stream \
  -platform oh2p \
  -audio default \
  -app "Desktop" \
  <server_ip> \
  > /var/log/moonlight-oh2p.log 2>&1 &
```

## 应用场景

### 1. 智能音箱

将 PC 音频串流到智能音箱，实现高质量音频播放。

```bash
./moonlight stream -platform oh2p -audio dmixer -app "Spotify" 192.168.1.100
```

### 2. 多房间音频

在多个房间部署音频设备，同步播放。

```bash
# 房间 A
./moonlight stream -platform oh2p -audio hw:0,0 -app "Desktop" 192.168.1.100 &

# 房间 B
./moonlight stream -platform oh2p -audio hw:1,0 -app "Desktop" 192.168.1.100 &
```

### 3. 无线音频接收器

将 ARM 设备作为无线音频接收器使用。

```bash
./moonlight stream -platform oh2p -audio plughw:0,0 -viewonly -app "Desktop" 192.168.1.100
```

### 4. 音频监控

远程监听服务器音频输出。

```bash
./moonlight stream -platform oh2p -audio default -viewonly -app "Desktop" 192.168.1.100
```

## 系统集成

### Systemd 服务

创建 `/etc/systemd/system/moonlight-oh2p.service`:

```ini
[Unit]
Description=Moonlight OH2P Audio Streaming
After=network.target sound.target

[Service]
Type=simple
User=moonlight
ExecStart=/usr/local/bin/moonlight stream -platform oh2p -audio dmixer -app "Desktop" 192.168.1.100
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启用服务:
```bash
sudo systemctl enable moonlight-oh2p
sudo systemctl start moonlight-oh2p
```

### 开机自启动

在 `/etc/rc.local` 中添加:

```bash
#!/bin/bash
/usr/local/bin/moonlight stream -platform oh2p -audio dmixer -app "Desktop" 192.168.1.100 &
exit 0
```

## 开发说明

### 代码结构

```
src/
├── platform.h          # 平台枚举定义
├── platform.c          # 平台实现（添加了 OH2P 支持）
├── main.c              # 主程序（更新了帮助信息）
└── audio/
    ├── alsa.c          # ALSA 音频实现（OH2P 使用）
    └── audio.h         # 音频接口定义
```

### 关键函数

1. **platform_check()**: 检测并返回平台类型
2. **platform_get_video()**: 返回视频回调（OH2P 返回 NULL）
3. **platform_get_audio()**: 返回音频回调（OH2P 返回 ALSA）
4. **platform_name()**: 返回平台名称

### 扩展开发

如需添加其他音频后端（如 PulseAudio），可以修改 `platform_get_audio()`:

```c
case OH2P:
  #ifdef HAVE_PULSE
  if (audio_pulse_init(audio_device))
    return &audio_callbacks_pulse;
  #endif
  #ifdef HAVE_ALSA
  return &audio_callbacks_alsa;
  #endif
```

## 测试

### 单元测试

```bash
# 测试平台检测
./moonlight -platform oh2p -verbose

# 测试音频设备
./moonlight stream -platform oh2p -audio default -debug <server_ip>
```

### 集成测试

```bash
# 完整流程测试
./oh2p-quickstart.sh
```

## 许可证

本修改遵循 Moonlight Embedded 的原始许可证（GNU General Public License v3.0）。

## 贡献

如有问题或建议，请提交 Issue 或 Pull Request。

## 更新日志

### v1.0.0 (2024-12-26)
- 初始实现 OH2P 平台支持
- 添加音频专用串流功能
- 支持 ALSA 音频输出
- 添加文档和示例文件

## 联系方式

如需技术支持，请参考 Moonlight Embedded 官方文档和社区。
