#!/bin/bash

# Serv00 VPS 工具脚本
# 适用于 serv00.com 免费 VPS (FreeBSD 系统)
# 作者: serv00-tool
# 版本: 1.0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 配置文件路径
CONFIG_DIR="$HOME/.serv00-tool"
CONFIG_FILE="$CONFIG_DIR/config"
LOG_FILE="$CONFIG_DIR/tool.log"

# 创建配置目录
mkdir -p "$CONFIG_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 显示横幅
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Serv00 VPS 工具箱                        ║"
    echo "║                  FreeBSD 环境管理工具                       ║"
    echo "║                     版本: 1.0                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

# 检查 binexec 状态
check_binexec() {
    echo -e "${YELLOW}检查 binexec 状态...${NC}"

    # 方法1: 使用 devil 命令检查状态
    if command -v devil >/dev/null 2>&1; then
        local devil_output
        devil_output=$(devil binexec 2>/dev/null || echo "")

        if echo "$devil_output" | grep -qi "enabled\|on\|active"; then
            echo -e "${GREEN}✓ Binexec 已启用 (通过 devil 命令确认)${NC}"
            return 0
        elif echo "$devil_output" | grep -qi "disabled\|off\|inactive"; then
            echo -e "${RED}✗ Binexec 未启用 (通过 devil 命令确认)${NC}"
            show_binexec_help
            return 1
        fi
    fi

    # 方法2: 创建测试脚本验证
    echo -e "${YELLOW}使用测试脚本验证 binexec 状态...${NC}"
    local test_script="/tmp/test_binexec_$$"

    # 写入测试脚本内容
    cat > "$test_script" << 'EOF'
#!/usr/local/bin/bash
echo "binexec_test_success"
EOF

    # 设置执行权限
    if chmod +x "$test_script" 2>/dev/null; then
        # 尝试执行测试脚本
        if "$test_script" 2>/dev/null | grep -q "binexec_test_success"; then
            echo -e "${GREEN}✓ Binexec 已启用 (通过测试脚本确认)${NC}"
            rm -f "$test_script"
            return 0
        else
            echo -e "${RED}✗ Binexec 未启用 (测试脚本执行失败)${NC}"
            show_binexec_help
            rm -f "$test_script"
            return 1
        fi
    else
        echo -e "${RED}✗ 无法创建测试脚本${NC}"
        rm -f "$test_script"
        return 1
    fi
}

# 显示 binexec 启用帮助
show_binexec_help() {
    echo
    echo -e "${YELLOW}如何启用 Binexec:${NC}"
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
}

# 显示系统信息
show_system_info() {
    echo -e "${BLUE}=== 系统信息 ===${NC}"
    echo -e "${WHITE}主机名:${NC} $(hostname)"
    echo -e "${WHITE}用户:${NC} $(whoami)"
    echo -e "${WHITE}当前目录:${NC} $(pwd)"
    echo -e "${WHITE}系统:${NC} $(uname -s) $(uname -r)"
    echo -e "${WHITE}架构:${NC} $(uname -m)"
    echo -e "${WHITE}运行时间:${NC} $(uptime | awk '{print $3,$4}' | sed 's/,//')"
    echo
    
    echo -e "${BLUE}=== 磁盘使用情况 ===${NC}"
    df -h ~ | tail -1 | awk '{printf "主目录: %s 已用 / %s 总计 (%s 使用率)\n", $3, $2, $5}'
    echo
    
    echo -e "${BLUE}=== 内存使用情况 ===${NC}"
    # FreeBSD 的内存信息获取方式
    if command -v top >/dev/null 2>&1; then
        top -n 1 | grep -E "Mem:|Swap:" | head -2
    fi
    echo
}

# 显示进程信息
show_processes() {
    echo -e "${BLUE}=== 用户进程 ===${NC}"
    echo -e "${WHITE}PID\t%CPU\t%MEM\tCOMMAND${NC}"
    ps aux | grep "^$(whoami)" | head -10 | awk '{printf "%s\t%s\t%s\t%s\n", $2, $3, $4, $11}'
    echo
    
    echo -e "${YELLOW}显示前10个进程，使用 'ps aux | grep \$(whoami)' 查看全部${NC}"
    echo
}

# 工具安装菜单
install_tools_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}=== 工具安装 ===${NC}"
        echo "1. 安装 screen (终端复用器)"
        echo "2. 安装 tmux (终端复用器)"
        echo "3. 安装 htop (系统监控)"
        echo "4. 安装 git (版本控制)"
        echo "5. 安装 nano (文本编辑器)"
        echo "6. 安装 wget (下载工具)"
        echo "7. 安装 curl (HTTP 客户端)"
        echo "8. 查看已安装的包"
        echo "9. 返回主菜单"
        echo
        read -p "请选择操作 [1-9]: " choice
        
        case $choice in
            1) install_package "screen" "终端复用器，允许在后台运行程序" ;;
            2) install_package "tmux" "现代化的终端复用器" ;;
            3) install_package "htop" "交互式系统监控工具" ;;
            4) install_package "git" "分布式版本控制系统" ;;
            5) install_package "nano" "简单易用的文本编辑器" ;;
            6) install_package "wget" "命令行下载工具" ;;
            7) install_package "curl" "HTTP 客户端工具" ;;
            8) list_installed_packages ;;
            9) break ;;
            *) echo -e "${RED}无效选择，请重试${NC}"; sleep 2 ;;
        esac
    done
}

# 安装包函数
install_package() {
    local package_name="$1"
    local description="$2"
    
    echo -e "${YELLOW}正在安装 $package_name ($description)...${NC}"
    log "开始安装包: $package_name"
    
    # 检查是否已安装
    if command -v "$package_name" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $package_name 已经安装${NC}"
        log "$package_name 已经安装"
    else
        # 尝试使用 pkg 安装
        echo -e "${YELLOW}使用 pkg 安装 $package_name...${NC}"
        if pkg install -y "$package_name" 2>/dev/null; then
            echo -e "${GREEN}✓ $package_name 安装成功${NC}"
            log "$package_name 安装成功"
        else
            echo -e "${RED}✗ $package_name 安装失败${NC}"
            echo -e "${YELLOW}提示: 某些包可能需要管理员权限或在 serv00 上不可用${NC}"
            log "$package_name 安装失败"
        fi
    fi
    
    echo
    read -p "按回车键继续..."
}

# 列出已安装的包
list_installed_packages() {
    echo -e "${BLUE}=== 已安装的用户包 ===${NC}"
    
    # 检查常用工具是否可用
    tools=("screen" "tmux" "htop" "git" "nano" "wget" "curl" "vim" "python3" "node" "ruby")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            version=$(command -v "$tool" 2>/dev/null && $tool --version 2>/dev/null | head -1 || echo "已安装")
            echo -e "${GREEN}✓${NC} $tool: $version"
        else
            echo -e "${RED}✗${NC} $tool: 未安装"
        fi
    done
    
    echo
    read -p "按回车键继续..."
}

# 服务管理菜单
service_management_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}=== 服务管理 ===${NC}"
        echo "1. 查看运行中的进程"
        echo "2. 启动 screen 会话"
        echo "3. 列出 screen 会话"
        echo "4. 连接到 screen 会话"
        echo "5. 杀死进程"
        echo "6. 查看端口使用情况"
        echo "7. 返回主菜单"
        echo
        read -p "请选择操作 [1-7]: " choice

        case $choice in
            1) show_processes; read -p "按回车键继续..." ;;
            2) start_screen_session ;;
            3) list_screen_sessions ;;
            4) attach_screen_session ;;
            5) kill_process_interactive ;;
            6) show_port_usage ;;
            7) break ;;
            *) echo -e "${RED}无效选择，请重试${NC}"; sleep 2 ;;
        esac
    done
}

# 启动 screen 会话
start_screen_session() {
    echo -e "${YELLOW}启动新的 screen 会话${NC}"
    read -p "请输入会话名称 (留空使用默认): " session_name

    if command -v screen >/dev/null 2>&1; then
        if [ -z "$session_name" ]; then
            screen
        else
            screen -S "$session_name"
        fi
    else
        echo -e "${RED}✗ screen 未安装，请先安装 screen${NC}"
        read -p "按回车键继续..."
    fi
}

# 列出 screen 会话
list_screen_sessions() {
    echo -e "${BLUE}=== Screen 会话列表 ===${NC}"

    if command -v screen >/dev/null 2>&1; then
        local sessions_output
        sessions_output=$(screen -ls 2>&1)

        if echo "$sessions_output" | grep -q "No Sockets found"; then
            echo -e "${YELLOW}当前没有运行中的 screen 会话${NC}"
            echo -e "${WHITE}提示: 使用 '启动 screen 会话' 创建新会话${NC}"
        else
            echo "$sessions_output"
        fi
    else
        echo -e "${RED}✗ screen 未安装${NC}"
        echo -e "${YELLOW}请先安装 screen: 主菜单 -> 工具安装 -> 安装 screen${NC}"
    fi

    echo
    read -p "按回车键继续..."
}

# 连接到 screen 会话
attach_screen_session() {
    if command -v screen >/dev/null 2>&1; then
        echo -e "${BLUE}=== 可用的 Screen 会话 ===${NC}"

        local sessions_output
        sessions_output=$(screen -ls 2>&1)

        if echo "$sessions_output" | grep -q "No Sockets found"; then
            echo -e "${YELLOW}当前没有运行中的 screen 会话${NC}"
            echo -e "${WHITE}请先创建一个 screen 会话${NC}"
            echo
            read -p "按回车键继续..."
            return
        fi

        echo "$sessions_output"
        echo
        read -p "请输入要连接的会话名称或ID (留空取消): " session_id

        if [ -n "$session_id" ]; then
            echo -e "${YELLOW}正在连接到会话 $session_id...${NC}"
            screen -r "$session_id"
        else
            echo -e "${YELLOW}操作已取消${NC}"
            read -p "按回车键继续..."
        fi
    else
        echo -e "${RED}✗ screen 未安装${NC}"
        echo -e "${YELLOW}请先安装 screen: 主菜单 -> 工具安装 -> 安装 screen${NC}"
        read -p "按回车键继续..."
    fi
}

# 交互式杀死进程
kill_process_interactive() {
    echo -e "${BLUE}=== 用户进程列表 ===${NC}"
    echo -e "${WHITE}PID\tCPU\tMEM\tCOMMAND${NC}"
    ps aux | grep "^$(whoami)" | awk '{printf "%s\t%s\t%s\t%s\n", $2, $3, $4, $11}' | head -20
    echo

    read -p "请输入要终止的进程 PID (留空取消): " pid

    if [ -n "$pid" ] && [[ "$pid" =~ ^[0-9]+$ ]]; then
        # 检查进程是否属于当前用户
        if ps -p "$pid" -o user= | grep -q "^$(whoami)$"; then
            echo -e "${YELLOW}确认要终止进程 $pid 吗? (y/N)${NC}"
            read -p "> " confirm

            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                if kill "$pid" 2>/dev/null; then
                    echo -e "${GREEN}✓ 进程 $pid 已终止${NC}"
                    log "终止进程: $pid"
                else
                    echo -e "${RED}✗ 无法终止进程 $pid${NC}"
                fi
            else
                echo -e "${YELLOW}操作已取消${NC}"
            fi
        else
            echo -e "${RED}✗ 进程 $pid 不属于当前用户或不存在${NC}"
        fi
    elif [ -n "$pid" ]; then
        echo -e "${RED}✗ 无效的 PID${NC}"
    fi

    echo
    read -p "按回车键继续..."
}

# 显示端口使用情况
show_port_usage() {
    echo -e "${BLUE}=== 端口使用情况 ===${NC}"

    # FreeBSD 使用 sockstat 命令
    if command -v sockstat >/dev/null 2>&1; then
        echo -e "${WHITE}用户进程监听的端口:${NC}"
        sockstat -l | grep "$(whoami)" | head -10
    else
        echo -e "${YELLOW}sockstat 命令不可用，尝试使用 netstat${NC}"
        if command -v netstat >/dev/null 2>&1; then
            netstat -an | grep LISTEN | head -10
        else
            echo -e "${RED}无法获取端口信息${NC}"
        fi
    fi

    echo
    read -p "按回车键继续..."
}

# 应用管理菜单
app_management_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}=== 应用管理 ===${NC}"
        echo "1. 创建新应用"
        echo "2. 列出所有应用"
        echo "3. 启动应用"
        echo "4. 停止应用"
        echo "5. 查看应用状态"
        echo "6. 删除应用"
        echo "7. 应用日志"
        echo "8. 安装 frps 服务"
        echo "9. 返回主菜单"
        echo
        read -p "请选择操作 [1-9]: " choice

        case $choice in
            1) create_new_app ;;
            2) list_apps ;;
            3) start_app ;;
            4) stop_app ;;
            5) show_app_status ;;
            6) delete_app ;;
            7) show_app_logs ;;
            8) install_frps ;;
            9) break ;;
            *) echo -e "${RED}无效选择，请重试${NC}"; sleep 2 ;;
        esac
    done
}

# 创建新应用
create_new_app() {
    echo -e "${BLUE}=== 创建新应用 ===${NC}"
    echo

    read -p "应用名称: " app_name
    if [ -z "$app_name" ]; then
        echo -e "${RED}应用名称不能为空${NC}"
        read -p "按回车键继续..."
        return
    fi

    # 检查应用是否已存在
    if [ -d "$HOME/apps/$app_name" ]; then
        echo -e "${RED}应用 $app_name 已存在${NC}"
        read -p "按回车键继续..."
        return
    fi

    echo "选择应用类型:"
    echo "1. Python Web 应用"
    echo "2. Node.js 应用"
    echo "3. 静态网站"
    echo "4. frp 客户端"
    echo "5. 通用应用"
    read -p "请选择 [1-5]: " app_type

    case $app_type in
        1) create_python_app "$app_name" ;;
        2) create_nodejs_app "$app_name" ;;
        3) create_static_app "$app_name" ;;
        4) create_frpc_app "$app_name" ;;
        5) create_generic_app "$app_name" ;;
        *) echo -e "${RED}无效选择${NC}"; read -p "按回车键继续..."; return ;;
    esac
}

# 创建 Python 应用
create_python_app() {
    local app_name="$1"
    local app_dir="$HOME/apps/$app_name"

    echo -e "${YELLOW}创建 Python 应用: $app_name${NC}"

    mkdir -p "$app_dir"
    cd "$app_dir"

    # 创建虚拟环境
    if command -v python3 >/dev/null 2>&1; then
        python3 -m venv venv
        echo -e "${GREEN}✓ Python 虚拟环境已创建${NC}"
    fi

    # 创建基本文件
    cat > app.py << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class MyHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<h1>Hello from Serv00!</h1><p>Python app is running.</p>')
        else:
            super().do_GET()

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    server = HTTPServer(('localhost', port), MyHandler)
    print(f"Server running on port {port}")
    server.serve_forever()
EOF

    cat > requirements.txt << 'EOF'
# Add your Python dependencies here
# flask
# django
# fastapi
EOF

    cat > start.sh << 'EOF'
#!/usr/local/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python app.py
EOF

    chmod +x start.sh

    # 创建应用配置
    create_app_config "$app_name" "python" "8000"

    echo -e "${GREEN}✓ Python 应用 $app_name 创建成功${NC}"
    echo -e "${WHITE}位置: $app_dir${NC}"
    echo -e "${WHITE}启动: cd $app_dir && ./start.sh${NC}"

    log "创建 Python 应用: $app_name"
    read -p "按回车键继续..."
}

# 创建 Node.js 应用
create_nodejs_app() {
    local app_name="$1"
    local app_dir="$HOME/apps/$app_name"

    echo -e "${YELLOW}创建 Node.js 应用: $app_name${NC}"

    mkdir -p "$app_dir"
    cd "$app_dir"

    # 创建 package.json
    cat > package.json << EOF
{
  "name": "$app_name",
  "version": "1.0.0",
  "description": "Serv00 Node.js application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "node app.js"
  },
  "dependencies": {
  }
}
EOF

    # 创建基本应用
    cat > app.js << 'EOF'
const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<h1>Hello from Serv00!</h1><p>Node.js app is running.</p>');
});

server.listen(port, 'localhost', () => {
    console.log(`Server running on port ${port}`);
});
EOF

    cat > start.sh << 'EOF'
#!/usr/local/bin/bash
cd "$(dirname "$0")"
node app.js
EOF

    chmod +x start.sh

    # 创建应用配置
    create_app_config "$app_name" "nodejs" "3000"

    echo -e "${GREEN}✓ Node.js 应用 $app_name 创建成功${NC}"
    echo -e "${WHITE}位置: $app_dir${NC}"
    echo -e "${WHITE}启动: cd $app_dir && ./start.sh${NC}"

    log "创建 Node.js 应用: $app_name"
    read -p "按回车键继续..."
}

# 创建 frp 客户端应用
create_frpc_app() {
    local app_name="$1"
    local app_dir="$HOME/apps/$app_name"

    echo -e "${YELLOW}创建 frp 客户端应用: $app_name${NC}"

    mkdir -p "$app_dir"
    cd "$app_dir"

    # 检测系统架构
    local arch=$(uname -m)
    local frp_arch=""
    case $arch in
        x86_64|amd64) frp_arch="amd64" ;;
        i386|i686) frp_arch="386" ;;
        aarch64|arm64) frp_arch="arm64" ;;
        armv7l) frp_arch="arm" ;;
        *)
            echo -e "${RED}✗ 不支持的架构: $arch${NC}"
            read -p "按回车键继续..."
            return
            ;;
    esac

    # 获取最新版本
    echo -e "${YELLOW}获取 frp 最新版本...${NC}"
    local latest_version=""
    if command -v curl >/dev/null 2>&1; then
        latest_version=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    elif command -v wget >/dev/null 2>&1; then
        latest_version=$(wget -qO- https://api.github.com/repos/fatedier/frp/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    fi

    if [ -z "$latest_version" ]; then
        latest_version="v0.52.3"  # 备用版本
        echo -e "${YELLOW}无法获取最新版本，使用默认版本: $latest_version${NC}"
    else
        echo -e "${GREEN}最新版本: $latest_version${NC}"
    fi

    # 下载 frp
    local download_url="https://github.com/fatedier/frp/releases/download/${latest_version}/frp_${latest_version#v}_freebsd_${frp_arch}.tar.gz"
    local filename="frp_${latest_version#v}_freebsd_${frp_arch}.tar.gz"

    echo -e "${YELLOW}下载 frp...${NC}"

    if command -v wget >/dev/null 2>&1; then
        wget -O "$filename" "$download_url"
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$filename" "$download_url"
    else
        echo -e "${RED}✗ 需要 wget 或 curl 来下载文件${NC}"
        read -p "按回车键继续..."
        return
    fi

    if [ ! -f "$filename" ]; then
        echo -e "${RED}✗ 下载失败${NC}"
        read -p "按回车键继续..."
        return
    fi

    # 解压文件
    echo -e "${YELLOW}解压文件...${NC}"
    tar -xzf "$filename"

    # 移动文件
    local extract_dir="frp_${latest_version#v}_freebsd_${frp_arch}"
    if [ -d "$extract_dir" ]; then
        cp "$extract_dir/frpc" .
        cp "$extract_dir/frpc.ini" .
        chmod +x frpc
        rm -rf "$extract_dir" "$filename"
        echo -e "${GREEN}✓ frpc 下载成功${NC}"
    else
        echo -e "${RED}✗ 解压失败${NC}"
        read -p "按回车键继续..."
        return
    fi

    # 配置 frpc
    setup_frpc_config

    # 创建应用配置
    create_app_config "$app_name" "frpc" "0"

    echo -e "${GREEN}✓ frp 客户端应用 $app_name 创建成功${NC}"
    echo -e "${WHITE}位置: $app_dir${NC}"
    echo -e "${WHITE}启动: 在应用管理中启动 $app_name${NC}"

    log "创建 frp 客户端应用: $app_name"
    read -p "按回车键继续..."
}

# 配置 frpc
setup_frpc_config() {
    echo -e "${YELLOW}配置 frp 客户端...${NC}"

    # 获取用户输入
    read -p "请输入 frps 服务器地址: " server_addr
    if [ -z "$server_addr" ]; then
        echo -e "${RED}服务器地址不能为空${NC}"
        return
    fi

    read -p "请输入 frps 服务器端口 (默认 7000): " server_port
    server_port=${server_port:-7000}

    read -p "请输入认证 token: " auth_token
    if [ -z "$auth_token" ]; then
        echo -e "${RED}认证 token 不能为空${NC}"
        return
    fi

    read -p "请输入本地服务名称 (如 ssh, web): " service_name
    service_name=${service_name:-ssh}

    read -p "请输入本地服务端口 (SSH=22, HTTP=80): " local_port
    local_port=${local_port:-22}

    read -p "请输入远程端口 (在服务器上暴露的端口): " remote_port
    if [ -z "$remote_port" ]; then
        echo -e "${RED}远程端口不能为空${NC}"
        return
    fi

    # 创建配置文件
    cat > frpc.ini << EOF
[common]
server_addr = $server_addr
server_port = $server_port
token = $auth_token

# 日志配置
log_file = ./frpc.log
log_level = info
log_max_days = 3

[$service_name]
type = tcp
local_ip = 127.0.0.1
local_port = $local_port
remote_port = $remote_port
EOF

    # 创建启动脚本
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "启动 frp 客户端..."
echo "配置文件: $(pwd)/frpc.ini"
echo "日志文件: $(pwd)/frpc.log"
echo "----------------------------------------"
./frpc -c frpc.ini
EOF

    chmod +x start.sh

    echo -e "${GREEN}✓ frp 客户端配置完成${NC}"
    echo
    echo -e "${WHITE}配置信息:${NC}"
    echo -e "  服务器: $server_addr:$server_port"
    echo -e "  本地服务: $service_name (127.0.0.1:$local_port)"
    echo -e "  远程端口: $remote_port"
    echo -e "  Token: $auth_token"
    echo
}

# 创建静态网站应用
create_static_app() {
    local app_name="$1"
    local app_dir="$HOME/apps/$app_name"

    echo -e "${YELLOW}创建静态网站应用: $app_name${NC}"

    mkdir -p "$app_dir"
    cd "$app_dir"

    # 创建基本 HTML 文件
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Serv00 静态网站</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .info { background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 静态网站运行成功！</h1>
        <div class="info">
            <p><strong>服务器:</strong> Serv00.com</p>
            <p><strong>系统:</strong> FreeBSD</p>
            <p><strong>时间:</strong> <span id="time"></span></p>
        </div>
        <p>这是一个运行在 Serv00 上的静态网站示例。</p>
        <p>你可以修改 index.html 文件来自定义网站内容。</p>
    </div>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

    # 创建简单的 HTTP 服务器脚本
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
port=${PORT:-8080}
echo "启动静态网站服务器..."
echo "访问地址: http://$(hostname):$port"
echo "文档根目录: $(pwd)"
echo "----------------------------------------"

# 使用 Python 启动简单 HTTP 服务器
if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server $port
elif command -v python >/dev/null 2>&1; then
    python -m SimpleHTTPServer $port
else
    echo "错误: 需要 Python 来运行 HTTP 服务器"
    exit 1
fi
EOF

    chmod +x start.sh

    # 创建应用配置
    create_app_config "$app_name" "static" "8080"

    echo -e "${GREEN}✓ 静态网站应用 $app_name 创建成功${NC}"
    echo -e "${WHITE}位置: $app_dir${NC}"
    echo -e "${WHITE}启动: cd $app_dir && ./start.sh${NC}"

    log "创建静态网站应用: $app_name"
    read -p "按回车键继续..."
}

# 创建通用应用
create_generic_app() {
    local app_name="$1"
    local app_dir="$HOME/apps/$app_name"

    echo -e "${YELLOW}创建通用应用: $app_name${NC}"

    mkdir -p "$app_dir"
    cd "$app_dir"

    # 创建基本启动脚本
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "通用应用启动脚本"
echo "请编辑此文件添加你的启动命令"
echo "当前目录: $(pwd)"
echo "----------------------------------------"

# 在这里添加你的启动命令
# 例如:
# ./your-program
# python your-script.py
# node your-app.js

echo "请编辑 start.sh 文件添加启动命令"
sleep 5
EOF

    chmod +x start.sh

    # 创建 README
    cat > README.md << 'EOF'
# 通用应用

这是一个通用应用模板。

## 使用方法

1. 将你的程序文件放在此目录
2. 编辑 `start.sh` 文件，添加启动命令
3. 通过应用管理启动应用

## 目录结构

```
your-app/
├── start.sh          # 启动脚本
├── README.md          # 说明文档
├── .app-config       # 应用配置（自动生成）
└── your-files...     # 你的程序文件
```

## 注意事项

- 确保你的程序有执行权限
- 长时间运行的程序会在 screen 会话中运行
- 查看日志可以通过应用管理功能
EOF

    # 创建应用配置
    create_app_config "$app_name" "generic" "0"

    echo -e "${GREEN}✓ 通用应用 $app_name 创建成功${NC}"
    echo -e "${WHITE}位置: $app_dir${NC}"
    echo -e "${WHITE}说明: 请编辑 start.sh 添加启动命令${NC}"

    log "创建通用应用: $app_name"
    read -p "按回车键继续..."
}

# 创建应用配置文件
create_app_config() {
    local app_name="$1"
    local app_type="$2"
    local default_port="$3"

    cat > .app-config << EOF
APP_NAME=$app_name
APP_TYPE=$app_type
DEFAULT_PORT=$default_port
CREATED=$(date)
STATUS=stopped
PID=
EOF
}

# 列出所有应用
list_apps() {
    echo -e "${BLUE}=== 应用列表 ===${NC}"

    if [ ! -d "$HOME/apps" ]; then
        echo -e "${YELLOW}还没有创建任何应用${NC}"
        read -p "按回车键继续..."
        return
    fi

    echo -e "${WHITE}名称\t\t类型\t\t状态\t\t端口${NC}"
    echo "----------------------------------------"

    for app_dir in "$HOME/apps"/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/.app-config" ]; then
            source "$app_dir/.app-config"
            local status_color="${RED}"
            if [ "$STATUS" = "running" ]; then
                status_color="${GREEN}"
            fi
            printf "%-15s\t%-10s\t${status_color}%-10s${NC}\t%s\n" \
                "$APP_NAME" "$APP_TYPE" "$STATUS" "$DEFAULT_PORT"
        fi
    done

    echo
    read -p "按回车键继续..."
}

# 启动应用
start_app() {
    echo -e "${BLUE}=== 启动应用 ===${NC}"

    read -p "请输入应用名称: " app_name
    if [ -z "$app_name" ]; then
        echo -e "${RED}应用名称不能为空${NC}"
        read -p "按回车键继续..."
        return
    fi

    local app_dir="$HOME/apps/$app_name"
    if [ ! -d "$app_dir" ] || [ ! -f "$app_dir/.app-config" ]; then
        echo -e "${RED}应用 $app_name 不存在${NC}"
        read -p "按回车键继续..."
        return
    fi

    cd "$app_dir"
    source .app-config

    if [ "$STATUS" = "running" ]; then
        echo -e "${YELLOW}应用 $app_name 已在运行中${NC}"
        read -p "按回车键继续..."
        return
    fi

    echo -e "${YELLOW}启动应用 $app_name...${NC}"

    # 在 screen 会话中启动应用
    if command -v screen >/dev/null 2>&1; then
        screen -dmS "$app_name" bash -c "cd '$app_dir' && ./start.sh"

        # 等待一下检查是否启动成功
        sleep 2
        if screen -list | grep -q "$app_name"; then
            # 更新配置
            sed -i '' "s/STATUS=.*/STATUS=running/" .app-config
            echo -e "${GREEN}✓ 应用 $app_name 启动成功${NC}"
            echo -e "${WHITE}Screen 会话: $app_name${NC}"
            log "启动应用: $app_name"
        else
            echo -e "${RED}✗ 应用 $app_name 启动失败${NC}"
        fi
    else
        echo -e "${RED}✗ screen 未安装，无法启动应用${NC}"
    fi

    read -p "按回车键继续..."
}

# 停止应用
stop_app() {
    echo -e "${BLUE}=== 停止应用 ===${NC}"

    read -p "请输入应用名称: " app_name
    if [ -z "$app_name" ]; then
        echo -e "${RED}应用名称不能为空${NC}"
        read -p "按回车键继续..."
        return
    fi

    local app_dir="$HOME/apps/$app_name"
    if [ ! -d "$app_dir" ] || [ ! -f "$app_dir/.app-config" ]; then
        echo -e "${RED}应用 $app_name 不存在${NC}"
        read -p "按回车键继续..."
        return
    fi

    echo -e "${YELLOW}停止应用 $app_name...${NC}"

    # 终止 screen 会话
    if screen -list | grep -q "$app_name"; then
        screen -S "$app_name" -X quit
        echo -e "${GREEN}✓ 应用 $app_name 已停止${NC}"

        # 更新配置
        cd "$app_dir"
        sed -i '' "s/STATUS=.*/STATUS=stopped/" .app-config
        log "停止应用: $app_name"
    else
        echo -e "${YELLOW}应用 $app_name 未在运行${NC}"
    fi

    read -p "按回车键继续..."
}

# 查看应用状态
show_app_status() {
    echo -e "${BLUE}=== 应用状态 ===${NC}"

    if [ ! -d "$HOME/apps" ]; then
        echo -e "${YELLOW}还没有创建任何应用${NC}"
        read -p "按回车键继续..."
        return
    fi

    for app_dir in "$HOME/apps"/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/.app-config" ]; then
            cd "$app_dir"
            source .app-config

            echo -e "${WHITE}应用: $APP_NAME${NC}"
            echo -e "  类型: $APP_TYPE"
            echo -e "  端口: $DEFAULT_PORT"
            echo -e "  创建时间: $CREATED"

            if screen -list | grep -q "$APP_NAME"; then
                echo -e "  状态: ${GREEN}运行中${NC}"
                echo -e "  Screen 会话: $APP_NAME"
            else
                echo -e "  状态: ${RED}已停止${NC}"
            fi
            echo
        fi
    done

    read -p "按回车键继续..."
}

# 安装 frps 服务
install_frps() {
    echo -e "${BLUE}=== 安装 frps 内网穿透服务 ===${NC}"
    echo

    # 检查是否已安装
    if [ -f "$HOME/apps/frps/frps" ]; then
        echo -e "${YELLOW}frps 已经安装${NC}"
        read -p "是否重新安装? (y/N): " reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            read -p "按回车键继续..."
            return
        fi
    fi

    echo -e "${YELLOW}正在安装 frps...${NC}"

    # 创建 frps 目录
    local frps_dir="$HOME/apps/frps"
    mkdir -p "$frps_dir"
    cd "$frps_dir"

    # 检测系统架构
    local arch=$(uname -m)
    local frp_arch=""
    case $arch in
        x86_64|amd64) frp_arch="amd64" ;;
        i386|i686) frp_arch="386" ;;
        aarch64|arm64) frp_arch="arm64" ;;
        armv7l) frp_arch="arm" ;;
        *)
            echo -e "${RED}✗ 不支持的架构: $arch${NC}"
            read -p "按回车键继续..."
            return
            ;;
    esac

    # 获取最新版本
    echo -e "${YELLOW}获取 frp 最新版本...${NC}"
    local latest_version=""
    if command -v curl >/dev/null 2>&1; then
        latest_version=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    elif command -v wget >/dev/null 2>&1; then
        latest_version=$(wget -qO- https://api.github.com/repos/fatedier/frp/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    fi

    if [ -z "$latest_version" ]; then
        latest_version="v0.52.3"  # 备用版本
        echo -e "${YELLOW}无法获取最新版本，使用默认版本: $latest_version${NC}"
    else
        echo -e "${GREEN}最新版本: $latest_version${NC}"
    fi

    # 下载 frp
    local download_url="https://github.com/fatedier/frp/releases/download/${latest_version}/frp_${latest_version#v}_freebsd_${frp_arch}.tar.gz"
    local filename="frp_${latest_version#v}_freebsd_${frp_arch}.tar.gz"

    echo -e "${YELLOW}下载 frp...${NC}"
    echo -e "${WHITE}URL: $download_url${NC}"

    if command -v wget >/dev/null 2>&1; then
        wget -O "$filename" "$download_url"
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$filename" "$download_url"
    else
        echo -e "${RED}✗ 需要 wget 或 curl 来下载文件${NC}"
        read -p "按回车键继续..."
        return
    fi

    if [ ! -f "$filename" ]; then
        echo -e "${RED}✗ 下载失败${NC}"
        read -p "按回车键继续..."
        return
    fi

    # 解压文件
    echo -e "${YELLOW}解压文件...${NC}"
    tar -xzf "$filename"

    # 移动文件
    local extract_dir="frp_${latest_version#v}_freebsd_${frp_arch}"
    if [ -d "$extract_dir" ]; then
        cp "$extract_dir/frps" .
        cp "$extract_dir/frps.ini" .
        chmod +x frps
        rm -rf "$extract_dir" "$filename"
        echo -e "${GREEN}✓ frps 安装成功${NC}"
    else
        echo -e "${RED}✗ 解压失败${NC}"
        read -p "按回车键继续..."
        return
    fi

    # 配置 frps
    setup_frps_config

    # 创建应用配置
    create_app_config "frps" "frps" "7000"

    echo -e "${GREEN}✓ frps 安装完成${NC}"
    echo -e "${WHITE}位置: $frps_dir${NC}"
    echo -e "${WHITE}配置文件: $frps_dir/frps.ini${NC}"
    echo -e "${WHITE}启动命令: 在应用管理中启动 frps${NC}"

    log "安装 frps 服务"
    read -p "按回车键继续..."
}

# 配置 frps
setup_frps_config() {
    echo -e "${YELLOW}配置 frps...${NC}"

    # 获取用户输入
    read -p "请输入 frps 监听端口 (默认 7000): " bind_port
    bind_port=${bind_port:-7000}

    read -p "请输入 dashboard 端口 (默认 7500): " dashboard_port
    dashboard_port=${dashboard_port:-7500}

    read -p "请输入 dashboard 用户名 (默认 admin): " dashboard_user
    dashboard_user=${dashboard_user:-admin}

    read -p "请输入 dashboard 密码 (默认 admin): " dashboard_pwd
    dashboard_pwd=${dashboard_pwd:-admin}

    read -p "请输入认证 token (留空随机生成): " auth_token
    if [ -z "$auth_token" ]; then
        auth_token=$(openssl rand -hex 16 2>/dev/null || echo "serv00-$(date +%s)")
    fi

    # 创建配置文件
    cat > frps.ini << EOF
[common]
# frps 监听端口
bind_port = $bind_port

# dashboard 配置
dashboard_port = $dashboard_port
dashboard_user = $dashboard_user
dashboard_pwd = $dashboard_pwd

# 认证配置
token = $auth_token

# 日志配置
log_file = ./frps.log
log_level = info
log_max_days = 3

# 其他配置
max_clients = 10
max_ports_per_client = 5

# 允许的端口范围（根据 serv00 限制调整）
allow_ports = 10000-65535
EOF

    # 创建启动脚本
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "启动 frps 服务..."
echo "配置文件: $(pwd)/frps.ini"
echo "日志文件: $(pwd)/frps.log"
echo "Dashboard: http://$(hostname):7500"
echo "认证 token: $(grep '^token' frps.ini | cut -d'=' -f2 | tr -d ' ')"
echo "----------------------------------------"
./frps -c frps.ini
EOF

    chmod +x start.sh

    echo -e "${GREEN}✓ frps 配置完成${NC}"
    echo
    echo -e "${WHITE}配置信息:${NC}"
    echo -e "  监听端口: $bind_port"
    echo -e "  Dashboard: http://$(hostname):$dashboard_port"
    echo -e "  用户名: $dashboard_user"
    echo -e "  密码: $dashboard_pwd"
    echo -e "  Token: $auth_token"
    echo
    echo -e "${YELLOW}重要提醒:${NC}"
    echo -e "  1. 请确保端口 $bind_port 和 $dashboard_port 在 serv00 允许范围内"
    echo -e "  2. 记住 token，客户端连接时需要使用"
    echo -e "  3. 可以通过 Dashboard 监控连接状态"
    echo
}

# 配置管理菜单
config_menu() {
    while true; do
        clear
        show_banner
        echo -e "${PURPLE}=== 配置管理 ===${NC}"
        echo "1. 查看当前配置"
        echo "2. 设置默认编辑器"
        echo "3. 配置 bash 环境"
        echo "4. 查看环境变量"
        echo "5. 备份配置文件"
        echo "6. 返回主菜单"
        echo
        read -p "请选择操作 [1-6]: " choice

        case $choice in
            1) show_current_config ;;
            2) set_default_editor ;;
            3) configure_bash_environment ;;
            4) show_environment_variables ;;
            5) backup_config_files ;;
            6) break ;;
            *) echo -e "${RED}无效选择，请重试${NC}"; sleep 2 ;;
        esac
    done
}

# 显示当前配置
show_current_config() {
    echo -e "${BLUE}=== 当前配置 ===${NC}"
    echo -e "${WHITE}默认编辑器:${NC} ${EDITOR:-未设置}"
    echo -e "${WHITE}Shell:${NC} $SHELL"
    echo -e "${WHITE}PATH:${NC} $PATH"
    echo -e "${WHITE}HOME:${NC} $HOME"
    echo -e "${WHITE}配置目录:${NC} $CONFIG_DIR"

    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${WHITE}工具配置文件:${NC} 存在"
        echo -e "${BLUE}配置内容:${NC}"
        cat "$CONFIG_FILE"
    else
        echo -e "${WHITE}工具配置文件:${NC} 不存在"
    fi

    echo
    read -p "按回车键继续..."
}

# 设置默认编辑器
set_default_editor() {
    echo -e "${BLUE}=== 设置默认编辑器 ===${NC}"
    echo "可用的编辑器:"
    echo "1. nano (推荐新手)"
    echo "2. vim"
    echo "3. vi"
    echo "4. ee"
    echo "5. 自定义"
    echo
    read -p "请选择编辑器 [1-5]: " choice

    case $choice in
        1) editor="nano" ;;
        2) editor="vim" ;;
        3) editor="vi" ;;
        4) editor="ee" ;;
        5) read -p "请输入编辑器命令: " editor ;;
        *) echo -e "${RED}无效选择${NC}"; return ;;
    esac

    if command -v "$editor" >/dev/null 2>&1; then
        echo "export EDITOR=\"$editor\"" >> ~/.bash_profile
        export EDITOR="$editor"
        echo -e "${GREEN}✓ 默认编辑器已设置为 $editor${NC}"
        echo -e "${YELLOW}请重新登录或运行 'source ~/.bash_profile' 使设置生效${NC}"
        log "设置默认编辑器: $editor"
    else
        echo -e "${RED}✗ 编辑器 $editor 不存在${NC}"
    fi

    echo
    read -p "按回车键继续..."
}

# 配置 bash 环境
configure_bash_environment() {
    echo -e "${BLUE}=== 配置 Bash 环境 ===${NC}"
    echo "1. 启用彩色 ls 输出"
    echo "2. 设置自定义提示符"
    echo "3. 添加常用别名"
    echo "4. 恢复默认设置"
    echo
    read -p "请选择操作 [1-4]: " choice

    case $choice in
        1) configure_colored_ls ;;
        2) configure_custom_prompt ;;
        3) add_common_aliases ;;
        4) restore_default_bash ;;
        *) echo -e "${RED}无效选择${NC}" ;;
    esac

    echo
    read -p "按回车键继续..."
}

# 配置彩色 ls
configure_colored_ls() {
    echo -e "${YELLOW}配置彩色 ls 输出...${NC}"

    if ! grep -q "LSCOLORS" ~/.bash_profile 2>/dev/null; then
        echo 'export LSCOLORS="ExGxFxdxCxDxDxhbadExEx"' >> ~/.bash_profile
        echo 'export CLICOLOR=1' >> ~/.bash_profile
        echo -e "${GREEN}✓ 彩色 ls 已启用${NC}"
        log "启用彩色 ls"
    else
        echo -e "${YELLOW}彩色 ls 已经配置${NC}"
    fi
}

# 添加常用别名
add_common_aliases() {
    echo -e "${YELLOW}添加常用别名...${NC}"

    aliases=(
        "alias ll='ls -la'"
        "alias la='ls -A'"
        "alias l='ls -CF'"
        "alias ..='cd ..'"
        "alias ...='cd ../..'"
        "alias grep='grep --color=auto'"
        "alias h='history'"
        "alias c='clear'"
    )

    for alias_cmd in "${aliases[@]}"; do
        if ! grep -q "$alias_cmd" ~/.bash_profile 2>/dev/null; then
            echo "$alias_cmd" >> ~/.bash_profile
        fi
    done

    echo -e "${GREEN}✓ 常用别名已添加${NC}"
    log "添加常用别名"
}

# 显示环境变量
show_environment_variables() {
    echo -e "${BLUE}=== 环境变量 ===${NC}"
    echo -e "${WHITE}重要环境变量:${NC}"
    env | grep -E "^(HOME|PATH|SHELL|USER|EDITOR|LANG|LC_)" | sort
    echo
    read -p "按回车键继续..."
}

# 备份配置文件
backup_config_files() {
    echo -e "${BLUE}=== 备份配置文件 ===${NC}"

    backup_dir="$HOME/backups/config_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    config_files=(
        ".bash_profile"
        ".bashrc"
        ".profile"
        ".vimrc"
        ".nanorc"
    )

    backed_up=0
    for file in "${config_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$backup_dir/"
            echo -e "${GREEN}✓${NC} 已备份 $file"
            ((backed_up++))
        fi
    done

    if [ $backed_up -gt 0 ]; then
        echo -e "${GREEN}✓ 配置文件已备份到: $backup_dir${NC}"
        log "备份配置文件到: $backup_dir"
    else
        echo -e "${YELLOW}没有找到需要备份的配置文件${NC}"
        rmdir "$backup_dir" 2>/dev/null
    fi

    echo
    read -p "按回车键继续..."
}

# 检查容器支持
check_container_support() {
    echo -e "${BLUE}=== 容器技术支持检查 ===${NC}"
    echo

    echo -e "${YELLOW}系统信息:${NC}"
    echo -e "  操作系统: $(uname -s) $(uname -r)"
    echo -e "  架构: $(uname -m)"
    echo -e "  用户: $(whoami)"
    echo

    echo -e "${YELLOW}Docker 检查:${NC}"
    if command -v docker >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker 命令可用${NC}"
        if docker ps >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Docker 可正常使用${NC}"
        else
            echo -e "${RED}✗ Docker 无权限或未运行${NC}"
        fi
    else
        echo -e "${RED}✗ Docker 未安装${NC}"
    fi

    echo -e "${YELLOW}Podman 检查:${NC}"
    if command -v podman >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Podman 命令可用${NC}"
        if podman ps >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Podman 可正常使用${NC}"
        else
            echo -e "${RED}✗ Podman 无法正常工作${NC}"
        fi
    else
        echo -e "${RED}✗ Podman 未安装${NC}"
    fi

    echo -e "${YELLOW}FreeBSD Jails 检查:${NC}"
    if command -v jail >/dev/null 2>&1; then
        echo -e "${GREEN}✓ jail 命令可用${NC}"
        if jls >/dev/null 2>&1; then
            echo -e "${GREEN}✓ 可以访问 jails${NC}"
        else
            echo -e "${RED}✗ 无权限访问 jails${NC}"
        fi
    else
        echo -e "${RED}✗ jail 命令不可用${NC}"
    fi

    echo
    echo -e "${CYAN}=== 结论 ===${NC}"
    echo -e "${RED}✗ 容器技术在 serv00 上不可用${NC}"
    echo -e "${WHITE}原因:${NC}"
    echo -e "  - FreeBSD 系统，Docker/Podman 支持有限"
    echo -e "  - 共享主机环境，无 root 权限"
    echo -e "  - 缺少必要的内核功能"
    echo
    echo -e "${GREEN}推荐替代方案:${NC}"
    echo -e "  - 使用本工具的应用管理功能"
    echo -e "  - 使用 screen/tmux 进行进程隔离"
    echo -e "  - 使用虚拟环境进行依赖隔离"
    echo
}

# 一键安装功能
quick_install() {
    echo -e "${CYAN}=== Serv00 工具箱一键安装 ===${NC}"
    echo

    # 检查环境
    if [ "$(uname -s)" != "FreeBSD" ]; then
        echo -e "${YELLOW}警告: 非 FreeBSD 系统，某些功能可能不可用${NC}"
    fi

    # 检查 binexec
    echo -e "${YELLOW}检查 binexec 状态...${NC}"
    if check_binexec >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Binexec 已启用${NC}"
    else
        echo -e "${RED}✗ Binexec 未启用${NC}"
        echo -e "${YELLOW}请先运行: devil binexec on${NC}"
        echo -e "${YELLOW}然后重新登录 SSH${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ 环境检查通过${NC}"
    echo

    # 创建目录结构
    echo -e "${YELLOW}创建目录结构...${NC}"
    mkdir -p "$HOME/apps"
    mkdir -p "$HOME/bin"
    mkdir -p "$CONFIG_DIR"

    # 创建命令链接
    if [ ! -L "$HOME/bin/serv00-tool" ]; then
        ln -s "$(realpath "$0")" "$HOME/bin/serv00-tool"
        echo -e "${GREEN}✓ 创建命令链接${NC}"
    fi

    # 添加到 PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
        echo -e "${GREEN}✓ 添加到 PATH${NC}"
    fi

    echo -e "${GREEN}✓ 安装完成！${NC}"
    echo
    echo -e "${WHITE}使用方法:${NC}"
    echo -e "  命令: ${CYAN}serv00-tool${NC}"
    echo -e "  或者: ${CYAN}$0${NC}"
    echo
}

# 主菜单
main_menu() {
    while true; do
        clear
        show_banner

        # 显示系统基本信息
        echo -e "${CYAN}当前用户: $(whoami)@$(hostname)${NC}"
        echo -e "${CYAN}当前目录: $(pwd)${NC}"
        echo

        echo -e "${WHITE}=== 主菜单 ===${NC}"
        echo "1. 系统信息"
        echo "2. 工具安装"
        echo "3. 服务管理"
        echo "4. 应用管理"
        echo "5. 配置管理"
        echo "6. 检查 binexec 状态"
        echo "7. 容器支持检查"
        echo "8. 查看日志"
        echo "9. 帮助信息"
        echo "0. 退出"
        echo
        read -p "请选择操作 [0-9]: " choice

        case $choice in
            1) clear; show_system_info; read -p "按回车键继续..." ;;
            2) install_tools_menu ;;
            3) service_management_menu ;;
            4) app_management_menu ;;
            5) config_menu ;;
            6) clear; check_binexec; read -p "按回车键继续..." ;;
            7) clear; check_container_support; read -p "按回车键继续..." ;;
            8) show_logs ;;
            9) show_help ;;
            0) echo -e "${GREEN}感谢使用 Serv00 工具箱！${NC}"; exit 0 ;;
            *) echo -e "${RED}无效选择，请重试${NC}"; sleep 2 ;;
        esac
    done
}

# 显示日志
show_logs() {
    echo -e "${BLUE}=== 工具日志 ===${NC}"

    if [ -f "$LOG_FILE" ]; then
        echo -e "${WHITE}最近 20 条日志:${NC}"
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}暂无日志记录${NC}"
    fi

    echo
    read -p "按回车键继续..."
}

# 显示帮助信息
show_help() {
    clear
    show_banner
    echo -e "${BLUE}=== 帮助信息 ===${NC}"
    echo
    echo -e "${WHITE}Serv00 工具箱使用说明:${NC}"
    echo
    echo -e "${YELLOW}1. 系统信息${NC}"
    echo "   - 查看系统基本信息、磁盘使用情况、内存状态等"
    echo
    echo -e "${YELLOW}2. 工具安装${NC}"
    echo "   - 安装常用工具如 screen、tmux、htop、git 等"
    echo "   - 使用 FreeBSD 的 pkg 包管理器"
    echo
    echo -e "${YELLOW}3. 服务管理${NC}"
    echo "   - 管理用户进程和 screen 会话"
    echo "   - 查看端口使用情况"
    echo
    echo -e "${YELLOW}4. 配置管理${NC}"
    echo "   - 配置 bash 环境、编辑器等"
    echo "   - 备份重要配置文件"
    echo
    echo -e "${YELLOW}5. Binexec${NC}"
    echo "   - 检查是否启用了运行自定义程序的权限"
    echo "   - 如未启用，请运行: devil binexec on"
    echo
    echo -e "${WHITE}注意事项:${NC}"
    echo "- 本工具专为 serv00.com 免费 VPS 设计"
    echo "- 基于 FreeBSD 系统，无 root 权限"
    echo "- 某些功能需要先启用 binexec"
    echo "- 配置文件保存在 ~/.serv00-tool/ 目录"
    echo
    read -p "按回车键返回主菜单..."
}

# 显示使用帮助
show_usage() {
    echo "Serv00 VPS 工具箱 - 使用说明"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -v, --version       显示版本信息"
    echo "  -i, --install       一键安装配置"
    echo "  -c, --check         检查 binexec 状态"
    echo "  --container-check   检查容器支持"
    echo "  --list-apps         列出所有应用"
    echo "  --start-app NAME    启动指定应用"
    echo "  --stop-app NAME     停止指定应用"
    echo
    echo "示例:"
    echo "  $0                  启动交互界面"
    echo "  $0 --install        一键安装配置"
    echo "  $0 --check          检查 binexec"
    echo "  $0 --start-app web  启动名为 web 的应用"
    echo
}

# 显示版本信息
show_version() {
    echo "Serv00 VPS 工具箱 v1.0"
    echo "适用于 serv00.com FreeBSD 环境"
    echo "作者: serv00-tool"
}

# 主程序入口
main() {
    # 处理命令行参数
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -i|--install)
            quick_install
            exit 0
            ;;
        -c|--check)
            check_binexec
            exit 0
            ;;
        --container-check)
            check_container_support
            exit 0
            ;;
        --list-apps)
            list_apps
            exit 0
            ;;
        --start-app)
            if [ -n "${2:-}" ]; then
                app_name="$2"
                echo "启动应用: $app_name"
                # 这里可以调用启动应用的函数
            else
                echo "错误: 请指定应用名称"
                echo "用法: $0 --start-app <应用名称>"
                exit 1
            fi
            exit 0
            ;;
        --stop-app)
            if [ -n "${2:-}" ]; then
                app_name="$2"
                echo "停止应用: $app_name"
                # 这里可以调用停止应用的函数
            else
                echo "错误: 请指定应用名称"
                echo "用法: $0 --stop-app <应用名称>"
                exit 1
            fi
            exit 0
            ;;
        "")
            # 无参数，启动交互界面
            ;;
        *)
            echo "错误: 未知选项 '$1'"
            echo "使用 '$0 --help' 查看帮助信息"
            exit 1
            ;;
    esac

    # 检查是否为 FreeBSD 系统
    if [ "$(uname -s)" != "FreeBSD" ]; then
        echo -e "${YELLOW}警告: 本工具专为 FreeBSD 系统设计，当前系统为 $(uname -s)${NC}"
        echo -e "${YELLOW}某些功能可能无法正常工作${NC}"
        echo
    fi

    # 记录启动日志
    log "Serv00 工具箱启动"

    # 显示欢迎信息
    clear
    show_banner
    echo -e "${GREEN}欢迎使用 Serv00 VPS 工具箱！${NC}"
    echo -e "${YELLOW}正在初始化...${NC}"
    sleep 2

    # 进入主菜单
    main_menu
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
