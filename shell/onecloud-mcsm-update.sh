#!/bin/bash
set -euo pipefail

# 备份路径
BACK_DAEMON="/opt/mcsm-back-daemon"
BACK_WEB="/opt/mcsm-back-web"
DEST_DAEMON="/opt/mcsmanager/daemon/data"
DEST_WEB="/opt/mcsmanager/web/data"

# 1. 备份当前数据
echo "正在备份 daemon/data..."
cp -r /opt/mcsmanager/daemon/data "$BACK_DAEMON"
echo "正在备份 web/data..."
cp -r /opt/mcsmanager/web/data "$BACK_WEB"

# 2. 移除旧安装
echo "移除旧版 MCSManager..."
rm -rf /opt/mcsmanager

# 3. 安装新版
echo "正在安装新版 MCSManager..."
wget -qO- https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-install.sh | bash

# 4. 恢复数据（先清空目标再恢复）
echo "恢复 daemon/data..."
rm -rf "$DEST_DAEMON"
mv "$BACK_DAEMON" "$DEST_DAEMON"

echo "恢复 web/data..."
rm -rf "$DEST_WEB"
mv "$BACK_WEB" "$DEST_WEB"

# 5. 清理残留备份
echo "清理临时备份文件..."
# rm -rf "$BACK_DAEMON" "$BACK_WEB"

echo "✅ 完成！数据已恢复到新安装中。"
