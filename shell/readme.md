# Onecloud-MCSM

适用于玩客云的mcsm微调版本

#### 使用 systemd 管理服务

为了方便管理，可以使用 `systemd` 来启动和管理 Onecloud-MCSM 的节点服务和 Web 面板服务。

##### 创建服务文件

在 `/etc/systemd/system` 目录下创建以下两个服务文件：

**onecloud-mcsm-daemon.service：**

```ini
[Unit]
Description=Onecloud-MCSM Node Daemon
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/mcsmanager/
ExecStart=/opt/mcsmanager/start-daemon.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**onecloud-mcsm-web.service：**

```ini
[Unit]
Description=Onecloud-MCSM Web Panel
After=network.target onecloud-mcsm-daemon.service

[Service]
Type=simple
WorkingDirectory=/opt/mcsmanager/
ExecStart=/opt/mcsmanager/start-web.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

##### 重新加载 systemd 配置

```bash
sudo systemctl daemon-reload
```

##### 启动和设置开机自启服务

```bash
# 启动节点服务
sudo systemctl start onecloud-mcsm-daemon
# 设置节点服务开机自启
sudo systemctl enable onecloud-mcsm-daemon

# 启动 Web 面板服务
sudo systemctl start onecloud-mcsm-web
# 设置 Web 面板服务开机自启
sudo systemctl enable onecloud-mcsm-web
```

##### 检查服务状态

```bash
sudo systemctl status onecloud-mcsm-daemon
sudo systemctl status onecloud-mcsm-web
```

