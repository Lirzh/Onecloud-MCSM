# armhf-MCSManager

适用于armhf的MCSM面板的微调版本

### 这里存放要用的脚本

#### 使用 systemd 管理服务

为了方便管理，可以使用 `systemd` 来启动和管理 armhf-MCSManager 的节点服务和 Web 面板服务。

##### 创建服务文件

在 `/etc/systemd/system` 目录下创建以下两个服务文件：

**armhf-mcsm-daemon.service：**

```ini
[Unit]
Description=armhf-MCSManager Node Daemon
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

**armhf-mcsm-web.service：**

```ini
[Unit]
Description=armhf-MCSManager Web Panel
After=network.target armhf-mcsm-daemon.service

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
sudo systemctl start armhf-mcsm-daemon
# 设置节点服务开机自启
sudo systemctl enable armhf-mcsm-daemon

# 启动 Web 面板服务
sudo systemctl start armhf-mcsm-web
# 设置 Web 面板服务开机自启
sudo systemctl enable armhf-mcsm-web
```

##### 检查服务状态

```bash
sudo systemctl status armhf-mcsm-daemon
sudo systemctl status armhf-mcsm-web
```

