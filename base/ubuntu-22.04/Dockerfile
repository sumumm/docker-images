FROM ubuntu:22.04

ARG UBUNTU_CODENAME="jammy"

# 指定字符集支持命令行输入中文、设置时区、避免交互式提示等
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# 修改软件源并更新软件包
RUN rm -f /etc/apt/sources.list.d/ubuntu.sources && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y curl wget unzip vim tree sudo

COPY ../../common/gitconfig /root/.gitconfig

# 创建用户 sumu，并设置终端颜色
RUN useradd -m -s /bin/bash sumu && \
    echo "sumu:000000" | chpasswd && \
    echo "root:000000" | chpasswd && \
    usermod -aG sudo sumu && \
    echo "PS1='\\[\\033[1;32m\\]\\u@\\h:\\[\\033[1;34m\\]\\w\\[\\033[0m\\]\\$ '" >> /home/sumu/.bashrc

USER sumu
