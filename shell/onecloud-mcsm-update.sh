#!/bin/bash
# onecloud-mcsm-update.sh - 修复版自动更新脚本（解决data目录不存在问题）

# 定义颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查是否为root用户
if [ "$(id -u)" -ne 0 ]; then
    log_error "请使用root用户执行此脚本"
    exit 1
fi

# 定义安装目录
INSTALL_DIR="/opt/mcsmanager"

# 检查安装目录是否存在
if [ ! -d "${INSTALL_DIR}" ]; then
    log_error "Onecloud-MCSM安装目录 ${INSTALL_DIR} 不存在"
    exit 1
fi

# 进入安装目录
cd "${INSTALL_DIR}" || {
    log_error "无法进入安装目录 ${INSTALL_DIR}"
    exit 1
}

# 检查关键文件是否存在（放宽检查条件）
if [ ! -f "start-web.sh" ] && [ ! -f "start-daemon.sh" ]; then
    log_error "在 ${INSTALL_DIR} 中未找到必要的面板文件"
    exit 1
fi

# 定义备份目录和当前日期
BACKUP_DIR="./backup"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DATA_DIR="${BACKUP_DIR}/data_${CURRENT_DATE}"
BACKUP_CONFIG_DIR="${BACKUP_DIR}/config_${CURRENT_DATE}"

# 停止服务
log_info "正在停止面板服务..."
sudo systemctl stop onecloud-mcsm-daemon
sudo systemctl stop onecloud-mcsm-web
sleep 3

# 检查服务是否已停止
if systemctl is-active --quiet onecloud-mcsm-daemon; then
    log_warning "daemon服务未能成功停止，继续执行更新"
fi

if systemctl is-active --quiet onecloud-mcsm-web; then
    log_warning "web服务未能成功停止，继续执行更新"
fi

# 备份配置文件（增加目录存在检查）
log_info "正在备份配置文件..."
mkdir -p "${BACKUP_DIR}"

# 备份data目录（如果存在）
if [ -d "./data" ]; then
    cp -r ./data "${BACKUP_DATA_DIR}" || {
        log_warning "备份data目录失败，但继续执行更新"
    }
else
    log_warning "未找到data目录，跳过备份"
fi

# 备份config目录（如果存在）
if [ -d "./config" ]; then
    cp -r ./config "${BACKUP_CONFIG_DIR}" || {
        log_warning "备份config目录失败，但继续执行更新"
    }
else
    log_warning "未找到config目录，跳过备份"
fi

# 备份服务配置文件
if [ -f "/etc/systemd/system/onecloud-mcsm-daemon.service" ]; then
    cp /etc/systemd/system/onecloud-mcsm-daemon.service "${BACKUP_DIR}/"
fi
if [ -f "/etc/systemd/system/onecloud-mcsm-web.service" ]; then
    cp /etc/systemd/system/onecloud-mcsm-web.service "${BACKUP_DIR}/"
fi

# 清理旧版本
log_info "正在清理旧版本文件..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
chmod 755 "${INSTALL_DIR}"
cd "${INSTALL_DIR}" || exit 1

# 下载并安装最新版本
log_info "正在下载最新版本..."
wget -qO- https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-install.sh | bash || {
    log_error "下载或执行安装脚本失败"
    exit 1
}

# 恢复配置文件（仅当备份存在时）
log_info "正在恢复配置文件..."
if [ -d "${BACKUP_DATA_DIR}" ]; then
    cp -r "${BACKUP_DATA_DIR}"/* ./data/ || {
        log_warning "恢复data目录失败"
    }
fi

if [ -d "${BACKUP_CONFIG_DIR}" ]; then
    cp -r "${BACKUP_CONFIG_DIR}"/* ./config/ || {
        log_warning "恢复config目录失败"
    }
fi

# 重新安装依赖
log_info "正在更新依赖库..."
if [ -f "./install.sh" ]; then
    ./install.sh || {
        log_warning "依赖安装失败，可能影响功能"
    }
else
    log_warning "未找到install.sh，跳过依赖安装"
fi

# 清理临时备份文件
log_info "正在清理临时文件..."
if [ -d "${BACKUP_DATA_DIR}" ]; then
    rm -rf "${BACKUP_DATA_DIR}"
fi
if [ -d "${BACKUP_CONFIG_DIR}" ]; then
    rm -rf "${BACKUP_CONFIG_DIR}"
fi
if [ -d "${BACKUP_DIR}" ] && [ -z "$(ls -A "${BACKUP_DIR}")" ]; then
    rm -rf "${BACKUP_DIR}"
fi

# 重新加载systemd配置
sudo systemctl daemon-reload

# 启动服务
log_info "更新完成，正在启动服务..."
sudo systemctl start onecloud-mcsm-daemon
sudo systemctl start onecloud-mcsm-web

# 检查服务状态
sleep 3
if systemctl is-active --quiet onecloud-mcsm-daemon && systemctl is-active --quiet onecloud-mcsm-web; then
    log_info "${GREEN}更新成功！面板已重新启动${NC}"
    log_info "访问 http://localhost:23333 查看更新结果"
else
    log_warning "服务启动可能存在问题，请检查状态："
    log_warning "sudo systemctl status onecloud-mcsm-daemon"
    log_warning "sudo systemctl status onecloud-mcsm-web"
fi
