#!/usr/local/bin/bash

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
    
    # 尝试运行一个简单的自定义命令来测试 binexec
    if echo '#!/usr/local/bin/bash\necho "test"' > /tmp/test_binexec.sh && chmod +x /tmp/test_binexec.sh; then
        if /tmp/test_binexec.sh >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Binexec 已启用${NC}"
            rm -f /tmp/test_binexec.sh
            return 0
        else
            echo -e "${RED}✗ Binexec 未启用${NC}"
            echo -e "${YELLOW}请运行以下命令启用 binexec:${NC}"
            echo -e "${WHITE}devil binexec on${NC}"
            echo -e "${YELLOW}然后重新登录 SSH${NC}"
            rm -f /tmp/test_binexec.sh
            return 1
        fi
    else
        echo -e "${RED}✗ 无法检查 binexec 状态${NC}"
        return 1
    fi
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
        screen -ls
    else
        echo -e "${RED}✗ screen 未安装${NC}"
    fi

    echo
    read -p "按回车键继续..."
}

# 连接到 screen 会话
attach_screen_session() {
    if command -v screen >/dev/null 2>&1; then
        echo -e "${BLUE}=== 可用的 Screen 会话 ===${NC}"
        screen -ls
        echo
        read -p "请输入要连接的会话名称或ID: " session_id

        if [ -n "$session_id" ]; then
            screen -r "$session_id"
        fi
    else
        echo -e "${RED}✗ screen 未安装${NC}"
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
        echo "4. 配置管理"
        echo "5. 检查 binexec 状态"
        echo "6. 查看日志"
        echo "7. 帮助信息"
        echo "8. 退出"
        echo
        read -p "请选择操作 [1-8]: " choice

        case $choice in
            1) clear; show_system_info; read -p "按回车键继续..." ;;
            2) install_tools_menu ;;
            3) service_management_menu ;;
            4) config_menu ;;
            5) clear; check_binexec; read -p "按回车键继续..." ;;
            6) show_logs ;;
            7) show_help ;;
            8) echo -e "${GREEN}感谢使用 Serv00 工具箱！${NC}"; exit 0 ;;
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

# 主程序入口
main() {
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
