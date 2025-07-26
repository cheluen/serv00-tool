# Serv00 VPS 工具箱

一个专为 [serv00.com](https://serv00.com) 免费 VPS 设计的**一体化管理工具**，基于 FreeBSD 系统。

## ✨ 核心特性

### 🖥️ 系统管理
- 系统信息查看（CPU、内存、磁盘）
- 用户进程监控和管理
- 端口使用情况查看

### 🛠️ 工具安装
- 一键安装：`screen`、`tmux`、`htop`、`git`、`nano`、`wget`、`curl`
- 自动检测已安装工具
- 使用 FreeBSD `pkg` 包管理器

### 📱 应用管理（新功能）
- **创建应用**：支持 Python Web、Node.js、静态网站、frp 客户端
- **frps 服务**：一键安装 frp 内网穿透服务端
- **应用隔离**：独立目录、虚拟环境、Screen 会话
- **生命周期管理**：启动、停止、状态监控
- **模板支持**：预配置的应用模板

### 🔧 服务管理
- Screen 会话管理（创建、连接、列出）
- 进程控制（启动、停止、监控）
- 服务状态查看

### ⚙️ 环境配置
- Bash 环境优化（彩色输出、别名）
- 默认编辑器设置
- 配置文件备份

### 🔍 诊断工具
- **Binexec 状态检查**：详细诊断和解决方案
- **容器支持检查**：Docker/Podman/Jails 兼容性
- 系统兼容性验证

## 🚀 快速开始

### 一键安装（推荐）
```bash
# 下载并运行
curl -s https://raw.githubusercontent.com/cheluen/serv00-tool/main/serv00-tool.sh | bash -s -- --install

# 或者分步安装
wget https://raw.githubusercontent.com/cheluen/serv00-tool/main/serv00-tool.sh
chmod +x serv00-tool.sh
./serv00-tool.sh --install
```

### 手动安装
```bash
# 1. 克隆仓库
git clone https://github.com/cheluen/serv00-tool.git
cd serv00-tool

# 2. 启用 binexec（重要！）
devil binexec on
exit  # 重新登录 SSH

# 3. 运行工具
./serv00-tool.sh
```

## 📋 使用方法

### 交互模式
```bash
./serv00-tool.sh
# 或安装后使用
serv00-tool
```

### 命令行模式
```bash
./serv00-tool.sh --help              # 显示帮助
./serv00-tool.sh --check             # 检查 binexec
./serv00-tool.sh --container-check   # 检查容器支持
./serv00-tool.sh --list-apps         # 列出应用
./serv00-tool.sh --start-app myapp   # 启动应用
./serv00-tool.sh --stop-app myapp    # 停止应用
```

## 🎯 应用管理示例

### 安装 frps 内网穿透服务
```bash
# 1. 进入应用管理
./serv00-tool.sh
# 选择 "4. 应用管理" -> "8. 安装 frps 服务"

# 2. 自动下载并配置 frps
# - 使用最新 TOML 配置格式
# - 配置 Dashboard、认证 token 等
# - 自动设置开机自启动

# 3. 启动 frps 服务
# 选择 "3. 启动应用" -> 输入 "frps"
# 或使用专门的 frps 管理菜单
```

### 创建 frp 客户端
```bash
# 1. 创建新应用
# 选择 "4. 应用管理" -> "1. 创建新应用" -> "4. frp 客户端"

# 2. 配置连接信息
# - 使用最新 TOML 配置格式
# - 服务器地址、端口、token、本地服务等

# 3. 启动客户端连接
```

### frps 专门管理
```bash
# 进入 frps 管理菜单
./serv00-tool.sh
# 选择 "4. 应用管理" -> "9. frps 管理"

# 功能包括：
# - 查看状态、启动/停止/重启服务
# - 查看日志、编辑配置文件
# - 测试开机自启、卸载服务
```

### 管理应用生命周期
```bash
# 查看所有应用
./serv00-tool.sh --list-apps

# 启动应用（命令行）
./serv00-tool.sh --start-app frps

# 停止应用（命令行）
./serv00-tool.sh --stop-app frps
```

## 📁 项目结构

```
serv00-tool/
├── serv00-tool.sh          # 🎯 唯一主脚本（包含所有功能）
├── README.md               # 📖 完整文档
└── LICENSE                 # 📄 许可证

运行后创建：
~/apps/                     # 应用目录
├── frps/                  # frp 服务端
├── webapp1/               # Python 应用
├── webapp2/               # Node.js 应用
├── frpc-client/           # frp 客户端
└── static-site/           # 静态网站

~/.serv00-tool/            # 配置目录
├── config                 # 配置文件
└── tool.log              # 日志文件
```

## ❓ 常见问题

### Q: 提示 "Binexec 未启用" 怎么办？
```bash
# 1. 启用 binexec
devil binexec on

# 2. 重新登录 SSH（重要！）
exit

# 3. 检查状态
./serv00-tool.sh --check
```

### Q: 能使用 Docker/Podman 吗？
**不能**。serv00 基于 FreeBSD，无 root 权限，不支持容器技术。
使用本工具的应用管理功能作为替代方案。

### Q: Screen 显示 "No Sockets found"？
这是正常的，表示没有运行中的 screen 会话。创建新应用时会自动创建会话。

### Q: 如何管理多个应用？
```bash
# 创建不同类型的应用
./serv00-tool.sh  # 选择应用管理

# 命令行管理
./serv00-tool.sh --list-apps
./serv00-tool.sh --start-app myapp
./serv00-tool.sh --stop-app myapp
```

### Q: frps 能在 serv00 上运行吗？
**可以！** 工具提供完整的 frps 支持：
- ✅ 自动下载适配 FreeBSD 的 frp 最新版本
- ✅ 使用最新 TOML 配置格式（不再使用 INI）
- ✅ 自动配置开机自启动（crontab + screen）
- ✅ 专门的 frps 管理界面
- ✅ 支持 Dashboard 和 Prometheus 监控
- ⚠️ 注意端口限制，使用 serv00 允许的端口范围

### Q: frps 配置文件在哪里？
安装完成后会显示配置文件位置：
- **TOML 配置**: `~/apps/frps/frps.toml`
- **启动脚本**: `~/apps/frps/start.sh`
- **自启脚本**: `~/apps/frps/autostart.sh`
- **日志文件**: `~/apps/frps/frps.log`

### Q: 如何修改 frps 配置？
```bash
# 方法1: 使用工具内置编辑器
./serv00-tool.sh
# 应用管理 -> frps 管理 -> 编辑配置文件

# 方法2: 直接编辑
nano ~/apps/frps/frps.toml
```

### Q: frps 开机自启动如何工作？
- ✅ 自动添加 crontab 任务：`@reboot ~/apps/frps/autostart.sh`
- ✅ 使用 screen 会话保持后台运行
- ✅ 可以通过 frps 管理菜单测试自启功能

## ⚠️ 重要说明

### 系统限制
- **无 root 权限**：共享主机环境
- **资源限制**：CPU、内存、磁盘有限制
- **网络限制**：某些端口不可用
- **容器不支持**：无法使用 Docker/Podman

### 最佳实践
1. **启用 binexec**：必须先运行 `devil binexec on`
2. **使用 screen**：长时间运行的程序放在 screen 中
3. **监控资源**：定期检查系统资源使用
4. **备份数据**：重要数据要备份

## 🔗 相关链接

- [Serv00 官网](https://serv00.com) - 免费 VPS 服务
- [Serv00 文档](https://docs.serv00.com) - 官方文档
- [FreeBSD 手册](https://www.freebsd.org/doc/) - 系统文档

---

**MIT License** | 仅供学习使用 | 遵守 serv00.com 使用条款
