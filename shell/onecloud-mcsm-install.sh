#!/bin/bash
# Onecloud-MCSM 一键安装脚本

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

# 检查是否为 root 用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "请使用 root 用户执行此脚本"
        exit 1
    fi
}

# 检查系统
check_system() {
    log_info "正在检查系统环境..."
    
    # 检查 Linux 发行版
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS="Debian"
        VER=$(cat /etc/debian_version)
    else
        log_warning "无法确定系统发行版，继续执行可能有风险"
        OS="Unknown"
        VER="Unknown"
    fi
    
    log_info "检测到系统: $OS $VER"
    
    # 检查架构
    ARCH=$(uname -m)
    log_info "系统架构: $ARCH"
    
    # 检查必要的命令
    for cmd in wget tar systemctl; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd 未安装，请先安装 $cmd"
            exit 1
        fi
    done
}

# 安装依赖
install_dependencies() {
    log_info "正在安装必要的依赖..."
    
    if [[ $OS == *"Ubuntu"* || $OS == *"Debian"* ]]; then
        apt update -y
        apt install -y wget tar
    elif [[ $OS == *"CentOS"* || $OS == *"Red Hat"* ]]; then
        yum update -y
        yum install -y wget tar
    else
        log_warning "未知系统，跳过依赖安装，请确保 wget 和 tar 已安装"
    fi
}

# 创建安装目录
create_install_dir() {
    log_info "正在创建安装目录..."
    
    # 创建目录
    mkdir -p /opt/mcsmanager/
    chmod 755 /opt/mcsmanager/
}

# 下载并安装服务
install_service() {
    log_info "正在下载 Onecloud-MCSM..."
    
    cd /opt/mcsmanager/
    
    # 下载 MCSManager
    wget https://github.com/lirzh/Onecloud-MCSM/releases/latest/download/mcsmanager_armv7l_release.tar.gz
    
    if [ $? -ne 0 ]; then
        log_error "下载失败，请检查网络连接或 URL 是否正确"
        log_info "如果无法下载，可以先科学上网下载再上传到服务器"
        exit 1
    fi
    
    log_info "正在解压文件..."
    tar -zxf mcsmanager_armv7l_release.tar.gz
    rm mcsmanager_armv7l_release.tar.gz
    
    log_info "Onecloud-MCSM 已成功安装到 /opt/mcsmanager/"
}

# 配置 systemd 服务
configure_systemd() {
    log_info "正在配置 systemd 服务..."
    
    # 创建节点服务文件
    log_info "下载 onecloud-mcsm-daemon.service..."
    wget -O /etc/systemd/system/onecloud-mcsm-daemon.service https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-daemon.service
    
    # 创建 Web 面板服务文件
    log_info "下载 onecloud-mcsm-web.service..."
    wget -O /etc/systemd/system/onecloud-mcsm-web.service https://raw.githubusercontent.com/Lirzh/Onecloud-MCSM/refs/heads/main/shell/onecloud-mcsm-web.service
    
    # 重新加载 systemd 配置
    systemctl daemon-reload
}

# 启动服务
start_service() {
    log_info "正在启动 Onecloud-MCSM 服务..."
    
    # 启动节点服务
    systemctl start onecloud-mcsm-daemon
    if [ $? -ne 0 ]; then
        log_error "节点服务启动失败"
    else
        # 设置节点服务开机自启
        systemctl enable onecloud-mcsm-daemon
        log_info "节点服务已启动并设置为开机自启"
    fi
    
    # 启动 Web 面板服务
    systemctl start onecloud-mcsm-web
    if [ $? -ne 0 ]; then
        log_error "Web 面板服务启动失败"
    else
        # 设置 Web 面板服务开机自启
        systemctl enable onecloud-mcsm-web
        log_info "Web 面板服务已启动并设置为开机自启"
    fi
}

# 显示安装完成信息
show_finish_info() {
    log_info "========================================="
    log_info "${GREEN}Onecloud-MCSM 安装完成！${NC}"
    log_info "========================================="
    log_info "服务管理命令:"
    log_info "  启动节点服务: systemctl start onecloud-mcsm-daemon"
    log_info "  停止节点服务: systemctl stop onecloud-mcsm-daemon"
    log_info "  重启节点服务: systemctl restart onecloud-mcsm-daemon"
    log_info "  查看节点服务状态: systemctl status onecloud-mcsm-daemon"
    log_info ""
    log_info "  启动 Web 面板: systemctl start onecloud-mcsm-web"
    log_info "  停止 Web 面板: systemctl stop onecloud-mcsm-web"
    log_info "  重启 Web 面板: systemctl restart onecloud-mcsm-web"
    log_info "  查看 Web 面板状态: systemctl status onecloud-mcsm-web"
    log_info ""
    log_info "访问地址: http://服务器IP:23333"
    log_info "========================================="
}

# 主函数
main() {
    echo -e "${GREEN}欢迎使用 Onecloud-MCSM 一键安装脚本！${NC}"
    echo "========================================="
    
    check_root
    check_system
    install_dependencies
    create_install_dir
    install_service
    configure_systemd
    start_service
    show_finish_info
}

# 执行主函数
main