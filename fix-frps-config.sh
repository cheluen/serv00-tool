#!/bin/bash

# frps 配置快速修复脚本
# 修复 allowPorts 字段格式错误

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${CYAN}=== frps 配置快速修复工具 ===${NC}"
echo

FRPS_DIR="$HOME/apps/frps"
CONFIG_FILE="$FRPS_DIR/frps.toml"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ 配置文件不存在: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}请先安装 frps 服务${NC}"
    exit 1
fi

cd "$FRPS_DIR"

echo -e "${YELLOW}检查配置文件...${NC}"

# 检查是否有语法错误
if [ -x "frps" ]; then
    if ./frps verify -c frps.toml >/dev/null 2>&1; then
        echo -e "${GREEN}✓ 配置文件语法正确，无需修复${NC}"
        exit 0
    else
        echo -e "${RED}✗ 检测到配置文件语法错误${NC}"
        ./frps verify -c frps.toml 2>&1 | head -3
    fi
else
    echo -e "${YELLOW}⚠ 无法验证配置语法（frps 不可执行）${NC}"
fi

echo

# 检查是否包含错误的 allowPorts 格式
if grep -q "allowPorts.*=" frps.toml; then
    echo -e "${YELLOW}检测到需要修复的 allowPorts 配置${NC}"
    
    # 备份原配置
    backup_file="frps.toml.backup.$(date +%Y%m%d_%H%M%S)"
    cp frps.toml "$backup_file"
    echo -e "${GREEN}✓ 已备份原配置: $backup_file${NC}"
    
    # 提取现有配置
    bind_port=$(grep 'bindPort.*=' frps.toml | cut -d'=' -f2 | tr -d ' ')
    web_port=$(grep 'port.*=' frps.toml | head -1 | cut -d'=' -f2 | tr -d ' ')
    web_user=$(grep 'user.*=' frps.toml | cut -d'"' -f2)
    web_pass=$(grep 'password.*=' frps.toml | cut -d'"' -f2)
    token=$(grep 'token.*=' frps.toml | cut -d'"' -f2)
    
    echo -e "${YELLOW}重新生成配置文件...${NC}"
    
    # 生成新的配置文件
    cat > frps.toml << EOF
# frps 服务端配置文件 (TOML 格式)
# 配置文档: https://gofrp.org/zh-cn/docs/reference/server-configures/

# 基本配置
bindAddr = "0.0.0.0"
bindPort = $bind_port

# Web 管理界面配置
[webServer]
addr = "0.0.0.0"
port = $web_port
user = "$web_user"
password = "$web_pass"

# 认证配置
[auth]
method = "token"
token = "$token"

# 日志配置
[log]
to = "./frps.log"
level = "info"
maxDays = 3

# 传输配置
[transport]
maxPoolCount = 5
tcpKeepalive = 7200

# 限制配置
maxPortsPerClient = 5

# 允许的端口范围
[[allowPorts]]
start = 10000
end = 65535

# 启用 Prometheus 监控 (可选)
enablePrometheus = true
EOF
    
    echo -e "${GREEN}✓ 配置文件已重新生成${NC}"
    
    # 验证新配置
    if [ -x "frps" ]; then
        if ./frps verify -c frps.toml >/dev/null 2>&1; then
            echo -e "${GREEN}✓ 新配置文件语法正确${NC}"
        else
            echo -e "${RED}✗ 新配置文件仍有错误，恢复备份${NC}"
            cp "$backup_file" frps.toml
            exit 1
        fi
    fi
    
    echo
    echo -e "${CYAN}=== 修复完成 ===${NC}"
    echo -e "${WHITE}配置信息:${NC}"
    echo -e "  监听端口: $bind_port"
    echo -e "  Dashboard: http://$(hostname):$web_port"
    echo -e "  用户名: $web_user"
    echo -e "  密码: $web_pass"
    echo -e "  Token: $token"
    echo
    echo -e "${YELLOW}建议操作:${NC}"
    echo -e "1. 重启 frps 服务以应用新配置"
    echo -e "2. 通过工具菜单: frp 内网穿透 -> frps 服务管理 -> 重启服务"
    echo
else
    echo -e "${GREEN}✓ 配置格式正确，无需修复${NC}"
fi

echo -e "${BLUE}修复完成！${NC}"
