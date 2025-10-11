# 使用 ARMHF 架构的 Debian 基础镜像
FROM arm32v7/debian:bullseye-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

# 设置工作目录
WORKDIR /opt/mcsmanager

# 安装必要的依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    tar \
    ca-certificates \
    nodejs \
    npm && \
    rm -rf /var/lib/apt/lists/*

# 创建安装目录
RUN mkdir -p /opt/mcsmanager/

# 下载并安装 MCSManager
RUN cd /opt && \
    wget https://github.com/Lirzh/armhf-MCSManager/releases/latest/download/mcsmanager_armv7l_release.tar.gz && \
    tar -zxf mcsmanager_armv7l_release.tar.gz && \
    rm mcsmanager_armv7l_release.tar.gz && \
    rm -r /opt/mcsmanager/web

# 安装Node.js依赖
RUN cd /opt/mcsmanager/daemon && \
    npm install

# 暴露端口
EXPOSE 24444

# 设置启动命令
CMD ["/opt/mcsmanager/start-daemon.sh"]