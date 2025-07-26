# Serv00 VPS 工具箱

一个专为 [serv00.com](https://serv00.com) 免费 VPS 设计的交互式管理工具，基于 FreeBSD 系统。

## 功能特性

### 🖥️ 系统信息
- 查看系统基本信息（主机名、用户、系统版本等）
- 显示磁盘使用情况
- 查看内存使用状态
- 监控用户进程

### 🛠️ 工具安装
- 一键安装常用工具：
  - `screen` - 终端复用器
  - `tmux` - 现代化终端复用器
  - `htop` - 交互式系统监控
  - `git` - 版本控制系统
  - `nano` - 简单文本编辑器
  - `wget` / `curl` - 下载工具
- 自动检测已安装的工具
- 使用 FreeBSD 的 `pkg` 包管理器

### 🔧 服务管理
- 查看和管理用户进程
- Screen 会话管理：
  - 创建新会话
  - 列出现有会话
  - 连接到指定会话
- 交互式进程终止
- 端口使用情况查看

### ⚙️ 配置管理
- 设置默认编辑器
- 配置 Bash 环境：
  - 启用彩色 ls 输出
  - 添加常用别名
  - 自定义提示符
- 查看环境变量
- 备份配置文件

### 🔐 Binexec 支持
- 检查 binexec 状态
- 提供启用指导

## 安装和使用

### 1. 下载工具

```bash
# 克隆仓库
git clone https://github.com/cheluen/serv00-tool.git
cd serv00-tool

# 或者直接下载脚本
wget https://raw.githubusercontent.com/cheluen/serv00-tool/main/serv00-tool.sh
```

### 2. 设置权限

```bash
chmod +x serv00-tool.sh
```

### 3. 启用 Binexec（重要）

在运行工具之前，需要启用 binexec 权限：

```bash
# 方法1: 使用 devil 命令
devil binexec on

# 方法2: 通过 DevilWEB 面板
# 登录 https://panel.serv00.com
# 进入 "Additional services" -> "Run your own applications"
# 启用 Binexec
```

**注意：启用 binexec 后需要重新登录 SSH！**

### 4. 运行工具

```bash
./serv00-tool.sh
```

## 界面预览

```
╔══════════════════════════════════════════════════════════════╗
║                    Serv00 VPS 工具箱                        ║
║                  FreeBSD 环境管理工具                       ║
║                     版本: 1.0                               ║
╚══════════════════════════════════════════════════════════════╝

当前用户: username@s1.serv00.com
当前目录: /usr/home/username

=== 主菜单 ===
1. 系统信息
2. 工具安装
3. 服务管理
4. 配置管理
5. 检查 binexec 状态
6. 查看日志
7. 帮助信息
8. 退出

请选择操作 [1-8]:
```

## 系统要求

- **操作系统**: FreeBSD（serv00.com 环境）
- **Shell**: Bash
- **权限**: 需要启用 binexec
- **网络**: 用于下载和安装软件包

## 目录结构

```
serv00-tool/
├── serv00-tool.sh          # 主脚本文件
├── README.md               # 说明文档
└── ~/.serv00-tool/         # 配置目录（运行后自动创建）
    ├── config              # 配置文件
    └── tool.log           # 日志文件
```

## 常见问题

### Q: 提示 "Binexec 未启用" 怎么办？
A: 运行 `devil binexec on` 命令，然后重新登录 SSH。

### Q: 无法安装某些软件包？
A: 某些软件包可能在 serv00 环境中不可用，或需要特殊权限。

### Q: Screen 会话无法启动？
A: 确保已安装 screen：在工具中选择 "工具安装" -> "安装 screen"。

### Q: 配置更改不生效？
A: 运行 `source ~/.bash_profile` 或重新登录 SSH。

## 注意事项

1. **权限限制**: serv00 是共享主机环境，没有 root 权限
2. **资源限制**: 注意 CPU 和内存使用限制
3. **网络限制**: 某些端口可能被限制
4. **存储限制**: 注意磁盘空间使用

## 支持的工具

| 工具 | 描述 | 状态 |
|------|------|------|
| screen | 终端复用器 | ✅ 支持 |
| tmux | 现代终端复用器 | ✅ 支持 |
| htop | 系统监控 | ✅ 支持 |
| git | 版本控制 | ✅ 支持 |
| nano | 文本编辑器 | ✅ 支持 |
| wget | 下载工具 | ✅ 支持 |
| curl | HTTP 客户端 | ✅ 支持 |

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 相关链接

- [Serv00 官网](https://serv00.com)
- [Serv00 文档](https://docs.serv00.com)
- [FreeBSD 手册](https://www.freebsd.org/doc/)

---

**免责声明**: 本工具仅供学习和个人使用，请遵守 serv00.com 的使用条款。
