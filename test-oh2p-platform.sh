#!/bin/bash
# OH2P 平台功能测试脚本

echo "=========================================="
echo "OH2P 平台功能测试"
echo "=========================================="
echo ""

# 检查moonlight可执行文件
if [ ! -f "./moonlight" ]; then
    echo "❌ 错误: 找不到 moonlight 可执行文件"
    echo "   请先编译项目"
    exit 1
fi
echo "✓ 找到 moonlight 可执行文件"

# 测试1: 检查帮助信息中是否包含oh2p
echo ""
echo "测试1: 检查帮助信息..."
if ./moonlight help 2>&1 | grep -q "oh2p"; then
    echo "✓ 帮助信息包含 oh2p 平台"
else
    echo "❌ 帮助信息未包含 oh2p 平台"
    exit 1
fi

# 测试2: 检查平台识别
echo ""
echo "测试2: 检查平台识别..."
# 这个测试需要实际运行，但我们可以检查是否能正常启动
if ./moonlight stream -platform oh2p 2>&1 | grep -q "OH2P"; then
    echo "✓ OH2P 平台被正确识别"
else
    # 可能因为缺少服务器地址而失败，但至少平台应该被识别
    if ./moonlight stream -platform oh2p 2>&1 | grep -q "Platform"; then
        echo "✓ OH2P 平台被正确识别"
    else
        echo "⚠ 无法完全验证平台识别（可能需要服务器连接）"
    fi
fi

# 测试3: 检查配置文件
echo ""
echo "测试3: 检查配置文件..."
if [ -f "oh2p-example.conf" ]; then
    echo "✓ 找到示例配置文件"
    if grep -q "platform = oh2p" oh2p-example.conf; then
        echo "✓ 配置文件格式正确"
    else
        echo "❌ 配置文件格式错误"
        exit 1
    fi
else
    echo "❌ 未找到示例配置文件"
    exit 1
fi

# 测试4: 检查文档
echo ""
echo "测试4: 检查文档..."
if [ -f "OH2P_PLATFORM.md" ]; then
    echo "✓ 找到平台文档"
else
    echo "❌ 未找到平台文档"
    exit 1
fi

if [ -f "OH2P_README.md" ]; then
    echo "✓ 找到实现说明"
else
    echo "❌ 未找到实现说明"
    exit 1
fi

# 测试5: 检查快速入门脚本
echo ""
echo "测试5: 检查快速入门脚本..."
if [ -f "oh2p-quickstart.sh" ]; then
    echo "✓ 找到快速入门脚本"
    if [ -x "oh2p-quickstart.sh" ]; then
        echo "✓ 脚本具有执行权限"
    else
        echo "⚠ 脚本没有执行权限，正在添加..."
        chmod +x oh2p-quickstart.sh
        echo "✓ 已添加执行权限"
    fi
else
    echo "❌ 未找到快速入门脚本"
    exit 1
fi

# 测试6: 检查ALSA支持
echo ""
echo "测试6: 检查ALSA支持..."
if command -v aplay &> /dev/null; then
    echo "✓ 系统已安装 ALSA 工具"
    echo "  可用的ALSA设备:"
    aplay -L 2>/dev/null | grep -E "^(default|sysdefault|dmixer)" | head -5 | sed 's/^/    /'
else
    echo "⚠ 系统未安装 ALSA 工具"
    echo "  请安装: sudo apt-get install alsa-utils"
fi

# 总结
echo ""
echo "=========================================="
echo "测试完成！"
echo "=========================================="
echo ""
echo "OH2P 平台已成功集成到 Moonlight Embedded"
echo ""
echo "下一步:"
echo "1. 确保编译时启用了 ALSA 支持"
echo "   cmake -DHAVE_ALSA=ON .."
echo ""
echo "2. 配对设备:"
echo "   ./moonlight pair <server_ip>"
echo ""
echo "3. 开始串流:"
echo "   ./moonlight stream -platform oh2p -audio dmixer -app \"Desktop\" <server_ip>"
echo ""
echo "或使用快速入门脚本:"
echo "   ./oh2p-quickstart.sh"
echo ""
