# Onecloud-MCSM
适用于玩客云的mcsm微调版本

## 关于二次开发

- **原作者**：[MCSManager](https://github.com/MCSManager)
- **原仓库**：[Github - MCSManager](https://github.com/MCSManager/MCSManager)
- **二次开发者**：[Lirzh](https://github.com/lirzh)
- **特别说明**：二次开发已征得 [原作者：yumao233 (Yumao)](https://github.com/yumao233)  的同意
- **协议**：Apache-2.0

## 简介

- **名字**：Onecloud-MCSM
- **原作者**：[MCSManager](https://github.com/MCSManager)
- **原仓库**：[Github - MCSManager](https://github.com/MCSManager/MCSManager)
- **二次开发者**：[Lirzh](https://github.com/lirzh)
- **特别说明**：二次开发已征得 [原作者：yumao233 (Yumao)](https://github.com/yumao233)  的同意
- **内容概括**：适用于玩客云的MCSM面板的微调版本
- **协议**：Apache-2.0
- **最后更新**：每日自动构建
- **关于AI**：该微调内容由AI告知，人工修改，机器编译。脚本由AI据MCSM官方脚本改写，人工审核，如有错误请联系作者。

## 使用方法

### 脚本安装（推荐）：

```
wget -qO- https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-install.sh | bash
```

然后......没有其他操作了，惊不惊喜！

### 脚本更新（推荐）：

```
wget -qO- https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-update.sh | bash
```

然后......没有其他操作了，惊不惊喜！

### 手动安装（麻烦，不推荐）：

**环境配置：**

请自行准备好 nodejs 20+，若无可用 apt 安装。 

##### 下载：

```
# 进入你的安装目录
mkdir /opt/mcsmanager/
cd /opt/mcsmanager/

# 下载 MCSManager（如果无法下载可以先科学上网下载再上传到服务器）
wget https://github.com/lirzh/Onecloud-MCSM/releases/latest/download/mcsmanager_armv7l_release.tar.gz

# 解压到安装目录
tar -zxf mcsmanager_armv7l_release.tar.gz
```

##### 安装：

```
# 进入你的安装目录
cd /opt/mcsmanager/

# 安装依赖库
./install.sh
```

##### 运行：

###### 使用 systemd 管理服务（推荐）：

请看[Onecloud-MCSM/shell at main · Lirzh/Onecloud-MCSM](https://github.com/Lirzh/Onecloud-MCSM/tree/main/shell)

###### 手动运行（不推荐）：

```
# 请使用 Screen 程序打开两个终端窗口（或者其他接管程序，如 pm2）

# 先启动节点程序
./start-daemon.sh

# 在第二个终端启动 Web 面板服务
./start-web.sh

# 为网络界面访问 http://localhost:23333/
# 一般来说，网络应用会自动扫描并连接到本地守护进程。
# 默认需要开放的端口：23333 和 24444
```






## 反馈问题和 Bug

如果你在使用过程中遇到问题或发现 Bug，可以前往 [本项目的 Issues 页面](https://github.com/lirzh/Onecloud-Mcsm/issues) 或是 [MCSM项目的 Issues 页面](https://github.com/MCSManager/MCSManager/issues) 提交反馈，我们 或 MCSM团队 会处理。

## 鸣谢

我们非常感谢所有为项目做出贡献的开发者（排名不分先后）：

[MCSManager](https://github.com/MCSManager)

[豆包AI](https://doubao.com)

## 参考文献

- [快速开始 | MCSManager](https://docs.mcsmanager.com/zh_cn/)
- [Github - MCSManager](https://github.com/MCSManager/MCSManager)

