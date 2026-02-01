# 作业目标：
# 构建 Golang Web 服务镜像，实现计数功能并连接 MySQL。
#
# 关键步骤说明：
# - 选择合适的 Golang 基础镜像
# - 下载依赖并编译应用
# - 拷贝可执行文件到最终镜像
# - 设置容器启动命令
# - 最好使用多阶段构建，减少最终镜像体积

# 阶段1：下载依赖并编译应用
# --------------------
FROM golang:1.21-alpine AS builder
# 在这里编写你的 Dockerfile

# 安装必要工具（如 go mod 下载需要）
RUN apk add --no-cache git
# 设置工作目录
WORKDIR /app
# 先拷贝 go.mod / go.sum，利用缓存
COPY go.mod ./go.mod
#COPY go.sum ./go.sum
# 下载依赖并整理依赖（利用Docker缓存加速）
RUN go mod download
# 再拷贝源码
COPY . .
RUN go mod tidy
# 编译（关闭 CGO，生成静态二进制，体积更小）
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o app

# 阶段2：运行
# --------------------
FROM alpine:latest
# 安装 CA 证书（MySQL / HTTP / TLS 常需要）
RUN apk add --no-cache ca-certificates curl
# 设置工作目录
WORKDIR /app
# 从 builder 阶段拷贝可执行文件
COPY --from=builder /app/app .
# 声明服务端口
EXPOSE 8080
# 启动应用
CMD ["./app"]