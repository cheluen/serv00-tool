#!/usr/local/bin/bash

# Serv00 工具箱安装脚本
# 自动下载并设置 serv00-tool

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示横幅
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                Serv00 工具箱 - 安装程序                     ║"
    echo "║                                                              ║"
    echo "║              正在为您安装 Serv00 VPS 工具箱                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

# 检查系统环境
check_environment() {
    echo -e "${YELLOW}检查系统环境...${NC}"
    
    # 检查是否为 FreeBSD
    if [ "$(uname -s)" != "FreeBSD" ]; then
        echo -e "${YELLOW}警告: 检测到非 FreeBSD 系统 ($(uname -s))${NC}"
        echo -e "${YELLOW}本工具专为 serv00.com 的 FreeBSD 环境设计${NC}"
        read -p "是否继续安装? (y/N): " continue_install
        if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
            echo -e "${RED}安装已取消${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ FreeBSD 系统检测通过${NC}"
    fi
    
    # 检查 bash
    if [ -z "$BASH_VERSION" ]; then
        echo -e "${RED}✗ 需要 Bash shell${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Bash shell 可用${NC}"
    fi
    
    # 检查基本命令
    commands=("wget" "curl" "chmod" "mkdir")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ $cmd 可用${NC}"
        else
            echo -e "${YELLOW}⚠ $cmd 不可用${NC}"
        fi
    done
    
    echo
}

# 检查 binexec 状态
check_binexec() {
    echo -e "${YELLOW}检查 binexec 状态...${NC}"
    
    # 创建测试脚本
    test_script="/tmp/test_binexec_$$"
    echo '#!/usr/local/bin/bash' > "$test_script"
    echo 'echo "binexec_test_ok"' >> "$test_script"
    chmod +x "$test_script"
    
    # 测试执行
    if "$test_script" 2>/dev/null | grep -q "binexec_test_ok"; then
        echo -e "${GREEN}✓ Binexec 已启用${NC}"
        rm -f "$test_script"
        return 0
    else
        echo -e "${RED}✗ Binexec 未启用${NC}"
        echo -e "${YELLOW}请先启用 binexec:${NC}"
        echo -e "${WHITE}  方法1: 运行命令 'devil binexec on'${NC}"
        echo -e "${WHITE}  方法2: 登录 panel.serv00.com -> Additional services -> Run your own applications${NC}"
        echo -e "${YELLOW}启用后请重新登录 SSH，然后重新运行此安装脚本${NC}"
        rm -f "$test_script"
        return 1
    fi
}

# 下载工具
download_tool() {
    echo -e "${YELLOW}下载 Serv00 工具箱...${NC}"
    
    # 设置下载目录
    INSTALL_DIR="$HOME/serv00-tool"
    
    # 如果目录已存在，询问是否覆盖
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}目录 $INSTALL_DIR 已存在${NC}"
        read -p "是否覆盖现有安装? (y/N): " overwrite
        if [[ "$overwrite" =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            echo -e "${GREEN}✓ 已删除现有目录${NC}"
        else
            echo -e "${RED}安装已取消${NC}"
            exit 1
        fi
    fi
    
    # 创建安装目录
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR" || exit 1
    
    # 尝试使用 git 克隆
    if command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}使用 git 克隆仓库...${NC}"
        if git clone https://github.com/cheluen/serv00-tool.git . 2>/dev/null; then
            echo -e "${GREEN}✓ Git 克隆成功${NC}"
            return 0
        else
            echo -e "${YELLOW}Git 克隆失败，尝试直接下载...${NC}"
        fi
    fi
    
    # 直接下载文件
    echo -e "${YELLOW}直接下载文件...${NC}"
    
    # 下载主脚本
    if command -v wget >/dev/null 2>&1; then
        wget -q https://raw.githubusercontent.com/cheluen/serv00-tool/main/serv00-tool.sh
        wget -q https://raw.githubusercontent.com/cheluen/serv00-tool/main/README.md
    elif command -v curl >/dev/null 2>&1; then
        curl -s -o serv00-tool.sh https://raw.githubusercontent.com/cheluen/serv00-tool/main/serv00-tool.sh
        curl -s -o README.md https://raw.githubusercontent.com/cheluen/serv00-tool/main/README.md
    else
        echo -e "${RED}✗ 无法下载文件 (wget 和 curl 都不可用)${NC}"
        return 1
    fi
    
    # 检查下载是否成功
    if [ -f "serv00-tool.sh" ]; then
        echo -e "${GREEN}✓ 文件下载成功${NC}"
        return 0
    else
        echo -e "${RED}✗ 文件下载失败${NC}"
        return 1
    fi
}

# 设置权限和创建链接
setup_tool() {
    echo -e "${YELLOW}设置工具权限...${NC}"
    
    # 设置执行权限
    chmod +x serv00-tool.sh
    echo -e "${GREEN}✓ 已设置执行权限${NC}"
    
    # 创建符号链接到 bin 目录
    BIN_DIR="$HOME/bin"
    mkdir -p "$BIN_DIR"
    
    if [ -L "$BIN_DIR/serv00-tool" ]; then
        rm "$BIN_DIR/serv00-tool"
    fi
    
    ln -s "$INSTALL_DIR/serv00-tool.sh" "$BIN_DIR/serv00-tool"
    echo -e "${GREEN}✓ 已创建命令链接${NC}"
    
    # 检查 PATH 中是否包含 ~/bin
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo -e "${YELLOW}添加 ~/bin 到 PATH...${NC}"
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
        export PATH="$HOME/bin:$PATH"
        echo -e "${GREEN}✓ 已添加到 PATH${NC}"
    fi
}

# 显示安装完成信息
show_completion() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    安装完成！                               ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}安装位置:${NC} $INSTALL_DIR"
    echo -e "${WHITE}可执行文件:${NC} $INSTALL_DIR/serv00-tool.sh"
    echo -e "${WHITE}命令链接:${NC} ~/bin/serv00-tool"
    echo
    echo -e "${CYAN}使用方法:${NC}"
    echo -e "${WHITE}  方法1: 直接运行${NC}"
    echo -e "    cd $INSTALL_DIR && ./serv00-tool.sh"
    echo
    echo -e "${WHITE}  方法2: 使用命令 (推荐)${NC}"
    echo -e "    serv00-tool"
    echo
    echo -e "${WHITE}  方法3: 重新登录后使用命令${NC}"
    echo -e "    source ~/.bash_profile"
    echo -e "    serv00-tool"
    echo
    echo -e "${YELLOW}注意事项:${NC}"
    echo -e "- 如果 binexec 未启用，请先运行: ${WHITE}devil binexec on${NC}"
    echo -e "- 启用 binexec 后需要重新登录 SSH"
    echo -e "- 查看 README.md 了解更多使用说明"
    echo
}

# 主安装流程
main() {
    show_banner
    
    echo -e "${CYAN}开始安装 Serv00 工具箱...${NC}"
    echo
    
    # 检查环境
    check_environment
    
    # 检查 binexec（非强制）
    if ! check_binexec; then
        echo
        read -p "Binexec 未启用，是否继续安装? (y/N): " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            echo -e "${RED}安装已取消${NC}"
            echo -e "${YELLOW}请先启用 binexec，然后重新运行安装脚本${NC}"
            exit 1
        fi
    fi
    
    echo
    
    # 下载工具
    if ! download_tool; then
        echo -e "${RED}下载失败，安装终止${NC}"
        exit 1
    fi
    
    # 设置工具
    setup_tool
    
    # 显示完成信息
    show_completion
    
    # 询问是否立即运行
    echo
    read -p "是否立即运行工具? (Y/n): " run_now
    if [[ ! "$run_now" =~ ^[Nn]$ ]]; then
        echo
        exec "$INSTALL_DIR/serv00-tool.sh"
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
