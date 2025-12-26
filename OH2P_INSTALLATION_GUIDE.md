# OH2P 平台安装和使用指南

## 目录
1. [系统要求](#系统要求)
2. [安装依赖](#安装依赖)
3. [编译项目](#编译项目)
4. [配置设备](#配置设备)
5. [开始使用](#开始使用)
6. [验证安装](#验证安装)

---

## 系统要求

### 硬件要求
- **处理器**: ARM32/ARM64 或 x86/x64
- **内存**: 最低 64MB RAM（推荐 128MB+）
- **存储**: 最低 50MB 可用空间
- **网络**: 有线或无线网络连接
- **音频**: ALSA 兼容的音频设备

### 软件要求
- **操作系统**: Linux（推荐 Debian/Ubuntu 或衍生版）
- **内核**: Linux 3.10+
- **ALSA**: libasound2 1.0.25+

### 推荐设备
- 树莓派 Zero/1/2/3/4
- Orange Pi
- Banana Pi
- 其他 ARM 开发板
- 智能音箱（支持 Linux）

---

## 安装依赖

### Debian/Ubuntu/Raspbian

```bash
# 更新包列表
sudo apt-get update

# 安装编译工具
sudo apt-get install -y \
    build-essential \
    cmake \
    git

# 安装必需依赖
sudo apt-get install -y \
    libasound2-dev \
    libopus-dev \
    libssl-dev \
    libavcodec-dev \
    libavutil-dev

# 安装可选依赖
sudo apt-get install -y \
    libevdev-dev \
    libudev-dev \
    libexpat1-dev

# 安装 ALSA 工具（用于测试）
sudo apt-get install -y \
    alsa-utils
```

### Arch Linux

```bash
sudo pacman -S \
    base-devel \
    cmake \
    git \
    alsa-lib \
    opus \
    openssl \
    ffmpeg
```

### Fedora/CentOS/RHEL

```bash
sudo dnf install -y \
    gcc \
    gcc-c++ \
    cmake \
    git \
    alsa-lib-devel \
    opus-devel \
    openssl-devel \
    ffmpeg-devel
```

---

## 编译项目

### 1. 克隆或获取源代码

如果你还没有源代码：

```bash
# 克隆仓库（如果适用）
git clone <repository-url>
cd moonlight-embedded
```

如果你已经有源代码，确保 OH2P 修改已应用。

### 2. 创建构建目录

```bash
mkdir -p build
cd build
```

### 3. 配置 CMake

```bash
# 基本配置（启用 ALSA）
cmake -DHAVE_ALSA=ON ..

# 或者，完整配置（推荐）
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DHAVE_ALSA=ON \
    -DHAVE_EMBEDDED=ON \
    ..
```

### 4. 编译

```bash
# 使用所有可用 CPU 核心编译
make -j$(nproc)

# 或者，单核编译（低端设备）
make
```

### 5. 安装（可选）

```bash
# 安装到系统
sudo make install

# 或者，仅复制可执行文件
sudo cp moonlight /usr/local/bin/
```

### 6. 验证编译

```bash
# 检查可执行文件
./moonlight help | grep oh2p

# 应该看到 oh2p 在平台列表中
```

---

## 配置设备

### 1. 配置 ALSA

#### 查看可用音频设备

```bash
# 列出所有 PCM 设备
aplay -L

# 列出声卡
aplay -l
```

#### 测试音频设备

```bash
# 测试默认设备
speaker-test -c 2 -t sine

# 测试特定设备
speaker-test -D dmixer -c 2 -t sine

# 播放测试音频（如果有）
aplay -D dmixer /usr/share/sounds/alsa/Front_Center.wav
```

#### 配置 ALSA（如需要）

创建或编辑 `~/.asoundrc`:

```bash
# 软件混音配置
pcm.dmixer {
    type dmix
    ipc_key 1024
    slave {
        pcm "hw:0,0"
        period_time 0
        period_size 1024
        buffer_size 4096
        rate 48000
    }
    bindings {
        0 0
        1 1
    }
}

pcm.!default {
    type plug
    slave.pcm "dmixer"
}
```

### 2. 创建证书目录

```bash
# 创建证书目录
mkdir -p /tmp/moonlight/certs

# 或者，使用持久化目录
mkdir -p ~/.cache/moonlight
```

### 3. 配置网络

确保设备可以访问串流服务器：

```bash
# 测试连接
ping <server_ip>

# 测试端口（默认 47989）
nc -zv <server_ip> 47989
```

---

## 开始使用

### 方法 1: 使用快速入门脚本（推荐新手）

```bash
# 返回项目根目录
cd ..

# 运行快速入门脚本
./oh2p-quickstart.sh
```

脚本会引导你完成：
1. 输入服务器 IP
2. 选择音频设备
3. 选择应用
4. 自动配对（如需要）
5. 开始串流

### 方法 2: 手动配置

#### 步骤 1: 配对设备

```bash
./moonlight pair -keydir=/tmp/moonlight/certs <server_ip>
```

在服务器上输入显示的 PIN 码。

#### 步骤 2: 查看可用应用

```bash
./moonlight list -keydir=/tmp/moonlight/certs <server_ip>
```

#### 步骤 3: 开始串流

```bash
./moonlight stream \
    -platform oh2p \
    -audio dmixer \
    -keydir=/tmp/moonlight/certs \
    -app "Desktop" \
    <server_ip>
```

### 方法 3: 使用配置文件

#### 步骤 1: 创建配置文件

```bash
# 复制示例配置
cp oh2p-example.conf my-config.conf

# 编辑配置
nano my-config.conf
```

修改以下内容：
- `address`: 你的服务器 IP
- `audio`: 你的 ALSA 设备
- `app`: 你要串流的应用

#### 步骤 2: 配对（如需要）

```bash
./moonlight pair <server_ip>
```

#### 步骤 3: 使用配置文件启动

```bash
./moonlight stream -config my-config.conf
```

---

## 验证安装

### 运行测试脚本

```bash
./test-oh2p-platform.sh
```

测试脚本会检查：
- ✓ moonlight 可执行文件
- ✓ oh2p 平台识别
- ✓ 配置文件
- ✓ 文档文件
- ✓ ALSA 支持

### 手动验证

#### 1. 检查平台支持

```bash
./moonlight help | grep oh2p
```

应该看到：
```
-platform <system>  ... /oh2p (default auto)
```

#### 2. 测试音频设备

```bash
speaker-test -D dmixer -c 2 -t sine -f 440 -l 1
```

应该听到 440Hz 的正弦波。

#### 3. 测试连接

```bash
./moonlight list <server_ip>
```

应该看到可用应用列表。

#### 4. 测试串流

```bash
./moonlight stream \
    -platform oh2p \
    -audio dmixer \
    -app "Desktop" \
    -verbose \
    <server_ip>
```

应该听到服务器的音频输出。

---

## 常见问题

### Q: 编译失败，提示找不到 ALSA

**A**: 安装 ALSA 开发库：
```bash
sudo apt-get install libasound2-dev
```

### Q: 音频无输出

**A**: 按顺序检查：
1. 测试 ALSA 设备: `speaker-test -D dmixer -c 2`
2. 检查音量: `alsamixer`
3. 尝试其他设备: `-audio default`
4. 查看详细日志: `-verbose` 或 `-debug`

### Q: 连接失败

**A**: 检查：
1. 网络连接: `ping <server_ip>`
2. 端口开放: `nc -zv <server_ip> 47989`
3. 重新配对: `./moonlight pair <server_ip>`
4. 防火墙设置

### Q: 音频延迟高

**A**: 优化：
1. 降低比特率: `-bitrate 3000`
2. 使用硬件设备: `-audio hw:0,0`
3. 使用有线网络
4. 检查 CPU 负载

### Q: 如何开机自启动？

**A**: 创建 systemd 服务（见 OH2P_README.md）

---

## 下一步

### 基础使用
- 阅读 [OH2P_QUICK_REFERENCE.md](OH2P_QUICK_REFERENCE.md) 了解常用命令
- 查看 [OH2P_PLATFORM.md](OH2P_PLATFORM.md) 了解详细功能

### 高级配置
- 阅读 [OH2P_README.md](OH2P_README.md) 了解系统集成
- 配置 systemd 服务实现开机自启动
- 优化 ALSA 配置降低延迟

### 故障排查
- 查看 [OH2P_PLATFORM.md](OH2P_PLATFORM.md) 的故障排查章节
- 使用 `-verbose` 或 `-debug` 参数查看详细日志
- 检查系统日志: `journalctl -xe`

---

## 支持

### 文档
- **快速参考**: OH2P_QUICK_REFERENCE.md
- **平台文档**: OH2P_PLATFORM.md
- **实现说明**: OH2P_README.md
- **修改总结**: OH2P_CHANGES_SUMMARY.md

### 社区
- Moonlight Embedded 官方文档
- GitHub Issues
- 社区论坛

---

**祝你使用愉快！享受高质量的音频串流体验！** 🎵
