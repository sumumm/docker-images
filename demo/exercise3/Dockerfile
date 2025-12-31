# 练习 3：Rust 多阶段构建
# 
# 要求：
# 1. 使用多阶段构建来优化 Rust 应用的 Docker 镜像
# 2. 第一阶段：
#    - 使用 rust:1.75-slim 作为基础镜像
#    - 设置工作目录
#    - 复制 Cargo.toml 和 Cargo.lock（如果存在）
#    - 复制源代码
#    - 安装 MUSL 目标环境, 支持交叉编译 rustup target add x86_64-unknown-linux-musl
#    - 使用 cargo build --target x86_64-unknown-linux-musl --release 构建应用
# 3. 第二阶段：
#    - 使用 alpine:latest 作为基础镜像
#    - 从第一阶段复制编译好的二进制文件
#    - 设置工作目录
#    - 运行应用
#
# 提示：
# 1. 使用 COPY --from=builder 从构建阶段复制文件
# 2. 注意文件权限和所有权
# 3. 确保最终镜像尽可能小, 小于 20 M
#
# 测试命令：
# docker build -t rust-exercise3 .
# docker run rust-exercise3

# 在这里编写你的 Dockerfile

# 第一阶段：构建阶段（使用Rust官方镜像）
# --------------------
FROM rust:1.75-slim as builder

# 设置工作目录为/workdir，后续命令都在此目录下执行
WORKDIR /workdir

# 复制Cargo配置文件
# Cargo.toml: 项目配置文件，包含依赖和项目元数据
# Cargo.lock*: 锁定依赖版本确保构建一致性，通配符用于处理可能不存在的文件
COPY Cargo.toml Cargo.lock* .

# 复制源代码目录到容器中的src目录
COPY src/ ./src

# 安装musl target以实现静态链接，创建独立的可执行文件
# 静态链接：将所有依赖打包进单个二进制文件，减少运行时依赖
# musl libc: 轻量级C标准库，适合容器环境
RUN rustup target add x86_64-unknown-linux-musl

# 构建应用，使用musl target并优化为发布版本
# --target: 指定目标架构和库为x86_64-unknown-linux-musl
# --release: 启用优化，移除调试信息，减小二进制大小
RUN cargo build --target x86_64-unknown-linux-musl --release

# 第二阶段：运行时阶段（使用Alpine Linux）
# --------------------
# Alpine是最小的Linux发行版，特别适合容器化应用
FROM alpine:latest

# 在运行时镜像中设置工作目录为/workdir
WORKDIR /workdir

# 从构建阶段复制编译好的可执行文件到当前镜像
# --from=builder: 从名为builder的构建阶段复制文件
# 复制路径：构建阶段中编译生成的静态链接二进制文件
COPY --from=builder /workdir/target/x86_64-unknown-linux-musl/release/rust-docker-example ./

# 设置容器启动时执行的默认命令, 运行构建好的Rust可执行文件
CMD ["./rust-docker-example"]
