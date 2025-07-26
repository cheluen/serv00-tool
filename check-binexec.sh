#!/usr/local/bin/bash

# Binexec 状态检查脚本
# 独立检查 serv00 的 binexec 状态

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Serv00 Binexec 状态检查 ===${NC}"
echo

# 检查系统信息
echo -e "${BLUE}系统信息:${NC}"
echo -e "  用户: $(whoami)"
echo -e "  主机: $(hostname)"
echo -e "  系统: $(uname -s) $(uname -r)"
echo

# 方法1: 检查 devil 命令
echo -e "${YELLOW}方法1: 检查 devil 命令...${NC}"
if command -v devil >/dev/null 2>&1; then
    echo -e "${GREEN}✓ devil 命令可用${NC}"
    
    echo -e "${BLUE}执行 'devil binexec' 命令:${NC}"
    devil_output=$(devil binexec 2>&1)
    echo "$devil_output"
    
    if echo "$devil_output" | grep -qi "enabled\|on\|active"; then
        echo -e "${GREEN}✓ Devil 显示 binexec 已启用${NC}"
        devil_status="enabled"
    elif echo "$devil_output" | grep -qi "disabled\|off\|inactive"; then
        echo -e "${RED}✗ Devil 显示 binexec 未启用${NC}"
        devil_status="disabled"
    else
        echo -e "${YELLOW}⚠ Devil 输出无法确定状态${NC}"
        devil_status="unknown"
    fi
else
    echo -e "${RED}✗ devil 命令不可用${NC}"
    devil_status="unavailable"
fi

echo

# 方法2: 测试脚本执行
echo -e "${YELLOW}方法2: 测试脚本执行...${NC}"

test_script="/tmp/binexec_test_$$"
cat > "$test_script" << 'EOF'
#!/usr/local/bin/bash
echo "BINEXEC_TEST_SUCCESS"
exit 0
EOF

if chmod +x "$test_script" 2>/dev/null; then
    echo -e "${GREEN}✓ 测试脚本创建成功${NC}"
    
    echo -e "${BLUE}执行测试脚本:${NC}"
    if script_output=$("$test_script" 2>&1); then
        if echo "$script_output" | grep -q "BINEXEC_TEST_SUCCESS"; then
            echo -e "${GREEN}✓ 测试脚本执行成功${NC}"
            echo -e "  输出: $script_output"
            script_status="success"
        else
            echo -e "${RED}✗ 测试脚本执行失败 (输出异常)${NC}"
            echo -e "  输出: $script_output"
            script_status="failed"
        fi
    else
        echo -e "${RED}✗ 测试脚本执行失败${NC}"
        echo -e "  错误: $script_output"
        script_status="failed"
    fi
    
    rm -f "$test_script"
else
    echo -e "${RED}✗ 无法创建测试脚本${NC}"
    script_status="error"
fi

echo

# 方法3: 检查进程执行权限
echo -e "${YELLOW}方法3: 检查进程执行权限...${NC}"

# 尝试执行一个简单的命令
if echo "test" | cat >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 基本命令执行正常${NC}"
else
    echo -e "${RED}✗ 基本命令执行异常${NC}"
fi

# 检查当前进程的执行权限
if [ -x "/usr/local/bin/bash" ]; then
    echo -e "${GREEN}✓ Bash 可执行${NC}"
else
    echo -e "${RED}✗ Bash 不可执行${NC}"
fi

echo

# 综合判断
echo -e "${CYAN}=== 综合判断 ===${NC}"

if [ "$script_status" = "success" ]; then
    echo -e "${GREEN}✓ Binexec 状态: 已启用${NC}"
    echo -e "${WHITE}  - 测试脚本可以正常执行${NC}"
    if [ "$devil_status" = "enabled" ]; then
        echo -e "${WHITE}  - Devil 命令确认已启用${NC}"
    fi
    final_status="enabled"
elif [ "$devil_status" = "enabled" ] && [ "$script_status" != "success" ]; then
    echo -e "${YELLOW}⚠ Binexec 状态: 可能已启用但有问题${NC}"
    echo -e "${WHITE}  - Devil 显示已启用，但测试脚本执行失败${NC}"
    echo -e "${WHITE}  - 建议重新登录 SSH 后再次测试${NC}"
    final_status="partial"
else
    echo -e "${RED}✗ Binexec 状态: 未启用${NC}"
    echo -e "${WHITE}  - 测试脚本无法执行${NC}"
    if [ "$devil_status" = "disabled" ]; then
        echo -e "${WHITE}  - Devil 命令确认未启用${NC}"
    fi
    final_status="disabled"
fi

echo

# 提供解决方案
if [ "$final_status" != "enabled" ]; then
    echo -e "${YELLOW}=== 启用 Binexec 的方法 ===${NC}"
    echo
    echo -e "${WHITE}方法1: 使用命令行${NC}"
    echo -e "  ${CYAN}devil binexec on${NC}"
    echo -e "  ${YELLOW}然后重新登录 SSH${NC}"
    echo
    echo -e "${WHITE}方法2: 使用 Web 面板${NC}"
    echo -e "  1. 登录 ${CYAN}https://panel.serv00.com${NC}"
    echo -e "  2. 进入 ${CYAN}Additional services${NC}"
    echo -e "  3. 点击 ${CYAN}Run your own applications${NC}"
    echo -e "  4. 启用 ${CYAN}Binexec${NC} 开关"
    echo -e "  5. 重新登录 SSH"
    echo
    echo -e "${WHITE}注意事项:${NC}"
    echo -e "  - 启用 binexec 后${RED}必须${NC}重新登录 SSH"
    echo -e "  - 某些更改可能需要几分钟才能生效"
    echo -e "  - 如果问题持续，请联系 serv00 支持"
else
    echo -e "${GREEN}=== Binexec 已正常工作 ===${NC}"
    echo -e "${WHITE}您可以正常运行自定义程序和脚本${NC}"
fi

echo
echo -e "${BLUE}检查完成！${NC}"
