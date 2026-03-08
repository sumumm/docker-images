# 第一阶段：下载和解压阶段
FROM alpine:latest AS builder

# 安装必要工具
RUN apk add --no-cache wget

# 下载 Ubuntu base rootfs
RUN wget -O /ubuntu-base.tar.gz \
    https://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.5-base-amd64.tar.gz

# 创建临时目录并解压
RUN mkdir /rootfs && \
    tar -xzf /ubuntu-base.tar.gz -C /rootfs

# 第二阶段：构建最终镜像
FROM scratch

# 从构建阶段复制已解压的文件系统
COPY --from=builder /rootfs/ /

# 设置环境变量
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 设置工作目录
WORKDIR /root

# 默认命令
CMD ["/bin/bash"]
