#!/bin/bash
# update.sh - 自动更新Onecloud-MCSM面板

# 检查是否在安装目录
cd /opt/mcsmanager
if [ ! -f "start-web.sh" ] || [ ! -f "start-daemon.sh" ]; then
    echo "错误：请在Onecloud-MCSM安装目录执行此脚本"
    exit 1
fi

# 定义备份目录和当前日期
BACKUP_DIR="./backup"
CURRENT_DATE=$(date +%Y%m%d)
BACKUP_DATA_DIR="${BACKUP_DIR}/data_${CURRENT_DATE}"
BACKUP_CONFIG_DIR="${BACKUP_DIR}/config_${CURRENT_DATE}"

# 停止服务
echo "正在停止面板服务..."
sudo systemctl stop onecloud-mcsm-daemon # 停止daemon服务
sudo systemctl stop onecloud-mcsm-web # 停止web服务
sleep 3

# 备份配置文件
echo "正在备份配置文件..."
mkdir -p ${BACKUP_DIR}
cp -r ./data ${BACKUP_DATA_DIR}
cp -r ./config ${BACKUP_CONFIG_DIR}

# 下载最新版本
echo "正在下载最新版本..."
wget -qO- https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-install.sh | bash

# 恢复配置文件
echo "正在恢复配置..."
cp -r ${BACKUP_DATA_DIR}/* ./data/
cp -r ${BACKUP_CONFIG_DIR}/* ./config/

# 新增：删除临时备份文件
echo "正在清理临时文件..."
if [ -d "${BACKUP_DATA_DIR}" ] && [ -d "${BACKUP_CONFIG_DIR}" ]; then
    rm -rf ${BACKUP_DATA_DIR}
    rm -rf ${BACKUP_CONFIG_DIR}
    # 如果backup目录为空则一并删除
    if [ -z "$(ls -A ${BACKUP_DIR})" ]; then
        rm -rf ${BACKUP_DIR}
    fi
    echo "临时文件清理完成"
else
    echo "警告：未找到备份文件，跳过清理步骤"
fi

# 启动服务
echo "更新完成，正在启动服务..."
# 启动节点服务
sudo systemctl start onecloud-mcsm-daemon=
# 启动 Web 面板服务
sudo systemctl start onecloud-mcsm-web

echo "更新成功！面板已重新启动"
echo "访问 http://localhost:23333 查看更新结果"
