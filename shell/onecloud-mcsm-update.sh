#!/bin/bash
# update.sh - 自动更新Onecloud-MCSM面板（优化版）

# 检查是否为root用户
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：请使用root用户执行此脚本"
    exit 1
fi

# 定义安装目录
INSTALL_DIR="/opt/mcsmanager"

# 检查安装目录是否存在
if [ ! -d "${INSTALL_DIR}" ]; then
    echo "错误：Onecloud-MCSM安装目录不存在"
    exit 1
fi

# 进入安装目录
cd "${INSTALL_DIR}" || {
    echo "错误：无法进入安装目录 ${INSTALL_DIR}"
    exit 1
}

# 检查关键文件是否存在
if [ ! -f "start-web.sh" ] || [ ! -f "start-daemon.sh" ]; then
    echo "错误：在 ${INSTALL_DIR} 中未找到必要的面板文件"
    exit 1
fi

# 定义备份目录和当前日期
BACKUP_DIR="./backup"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)  # 增加时间戳避免同一天多次备份冲突
BACKUP_DATA_DIR="${BACKUP_DIR}/data_${CURRENT_DATE}"
BACKUP_CONFIG_DIR="${BACKUP_DIR}/config_${CURRENT_DATE}"

# 停止服务
echo "正在停止面板服务..."
sudo systemctl stop onecloud-mcsm-daemon  # 停止daemon服务
sudo systemctl stop onecloud-mcsm-web     # 停止web服务
sleep 3

# 检查服务是否已停止
if systemctl is-active --quiet onecloud-mcsm-daemon; then
    echo "错误：daemon服务未能成功停止"
    exit 1
fi

if systemctl is-active --quiet onecloud-mcsm-web; then
    echo "错误：web服务未能成功停止"
    exit 1
fi

# 备份配置文件
echo "正在备份配置文件..."
mkdir -p "${BACKUP_DIR}"
cp -r ./data "${BACKUP_DATA_DIR}" || {
    echo "错误：备份data目录失败"
    exit 1
}
cp -r ./config "${BACKUP_CONFIG_DIR}" || {
    echo "错误：备份config目录失败"
    exit 1
}

# 清理旧版本（保留服务配置文件）
echo "正在清理旧版本文件..."
# 先备份服务文件（如果存在）
if [ -f "/etc/systemd/system/onecloud-mcsm-daemon.service" ]; then
    cp /etc/systemd/system/onecloud-mcsm-daemon.service "${BACKUP_DIR}/"
fi
if [ -f "/etc/systemd/system/onecloud-mcsm-web.service" ]; then
    cp /etc/systemd/system/onecloud-mcsm-web.service "${BACKUP_DIR}/"
fi

# 删除安装目录
rm -rf "${INSTALL_DIR}"
# 重新创建安装目录
mkdir -p "${INSTALL_DIR}"
chmod 755 "${INSTALL_DIR}"

# 下载并执行最新安装脚本
echo "正在下载并安装最新版本..."
wget -qO- https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-install.sh | bash || {
    echo "错误：下载或执行安装脚本失败"
    exit 1
}

# 进入新安装的目录
cd "${INSTALL_DIR}" || {
    echo "错误：安装后无法进入目录 ${INSTALL_DIR}"
    exit 1
}

# 恢复配置文件
echo "正在恢复配置文件..."
if [ -d "${BACKUP_DATA_DIR}" ]; then
    cp -r "${BACKUP_DATA_DIR}"/* ./data/ || {
        echo "警告：恢复data目录失败"
    }
else
    echo "警告：未找到data备份目录，无法恢复"
fi

if [ -d "${BACKUP_CONFIG_DIR}" ]; then
    cp -r "${BACKUP_CONFIG_DIR}"/* ./config/ || {
        echo "警告：恢复config目录失败"
    }
else
    echo "警告：未找到config备份目录，无法恢复"
fi

# 重新安装依赖（确保兼容性）
echo "正在更新依赖库..."
./install.sh || {
    echo "警告：依赖安装失败，可能影响功能"
}

# 清理临时备份文件
echo "正在清理临时文件..."
if [ -d "${BACKUP_DATA_DIR}" ] && [ -d "${BACKUP_CONFIG_DIR}" ]; then
    rm -rf "${BACKUP_DATA_DIR}"
    rm -rf "${BACKUP_CONFIG_DIR}"
    # 如果backup目录为空则一并删除
    if [ -z "$(ls -A "${BACKUP_DIR}")" ]; then
        rm -rf "${BACKUP_DIR}"
    fi
    echo "临时文件清理完成"
else
    echo "警告：未找到备份文件，跳过清理步骤"
fi

# 启动服务（修复语法错误）
echo "更新完成，正在启动服务..."
sudo systemctl start onecloud-mcsm-daemon  # 启动节点服务（移除多余的等号）
sudo systemctl start onecloud-mcsm-web     # 启动Web面板服务

# 检查服务状态
sleep 3
if systemctl is-active --quiet onecloud-mcsm-daemon && systemctl is-active --quiet onecloud-mcsm-web; then
    echo "更新成功！面板已重新启动"
    echo "访问 http://localhost:23333 查看更新结果"
else
    echo "警告：服务启动可能存在问题，请检查状态："
    echo "sudo systemctl status onecloud-mcsm-daemon"
    echo "sudo systemctl status onecloud-mcsm-web"
fi
