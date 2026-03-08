# 第一阶段：构建阶段
FROM ubuntu:latest AS builder
WORKDIR /app
COPY hello.txt .

# 第二阶段：运行阶段
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello.txt .
