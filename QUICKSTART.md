# Serv00 工具箱 - 快速开始

## 一键安装

在 serv00 VPS 上运行以下命令：

```bash
# 方法1: 使用安装脚本（推荐）
bash <(curl -s https://raw.githubusercontent.com/cheluen/serv00-tool/main/install.sh)

# 方法2: 手动安装
git clone https://github.com/cheluen/serv00-tool.git
cd serv00-tool
chmod +x serv00-tool.sh
./serv00-tool.sh
```

## 重要前置步骤

### 1. 启用 Binexec

**必须先启用 binexec 才能运行自定义程序！**

```bash
# 启用 binexec
devil binexec on

# 重新登录 SSH（重要！）
exit
# 然后重新 SSH 登录
```

或者通过 Web 面板：
1. 登录 https://panel.serv00.com
2. 进入 "Additional services"
3. 点击 "Run your own applications"
4. 启用 Binexec 开关

### 2. 运行工具

```bash
# 如果使用安装脚本安装
serv00-tool

# 或者直接运行
./serv00-tool.sh
```

## 主要功能

### 🖥️ 系统信息
- 查看主机信息、磁盘使用、内存状态
- 监控用户进程

### 🛠️ 工具安装
- 一键安装 screen、tmux、htop、git 等
- 自动检测已安装工具

### 🔧 服务管理
- Screen 会话管理
- 进程监控和终止
- 端口使用查看

### ⚙️ 配置管理
- 设置默认编辑器
- 配置 Bash 环境
- 备份配置文件

## 常用操作

### 安装 Screen
1. 运行工具 → 选择 "2. 工具安装"
2. 选择 "1. 安装 screen"
3. 等待安装完成

### 创建 Screen 会话
1. 运行工具 → 选择 "3. 服务管理"
2. 选择 "2. 启动 screen 会话"
3. 输入会话名称或留空使用默认

### 配置彩色输出
1. 运行工具 → 选择 "4. 配置管理"
2. 选择 "3. 配置 bash 环境"
3. 选择 "1. 启用彩色 ls 输出"

## 故障排除

### 问题：提示 "Binexec 未启用"
**解决方案：**
```bash
devil binexec on
exit  # 重新登录
```

### 问题：无法安装软件包
**可能原因：**
- 网络连接问题
- 软件包在 serv00 上不可用
- 需要特殊权限

### 问题：Screen 无法启动
**解决方案：**
```bash
# 先安装 screen
pkg install screen
# 或使用工具安装
```

### 问题：配置不生效
**解决方案：**
```bash
source ~/.bash_profile
# 或重新登录 SSH
```

## 目录结构

```
~/serv00-tool/              # 工具安装目录
├── serv00-tool.sh          # 主程序
├── README.md               # 详细文档
└── install.sh              # 安装脚本

~/.serv00-tool/             # 配置目录
├── config                  # 配置文件
└── tool.log               # 日志文件

~/bin/                      # 命令目录
└── serv00-tool            # 命令链接
```

## 使用技巧

1. **定期备份配置**：使用工具的配置管理功能备份重要配置文件
2. **使用 Screen**：对于长时间运行的任务，建议在 screen 会话中执行
3. **监控资源**：定期查看系统信息，避免超出资源限制
4. **查看日志**：遇到问题时查看工具日志获取详细信息

## 下一步

- 阅读完整的 [README.md](README.md) 了解所有功能
- 查看 [config.example](config.example) 了解配置选项
- 访问 [Serv00 文档](https://docs.serv00.com) 了解更多平台信息

---

**需要帮助？** 请在 GitHub 上提交 Issue 或查看文档。
