# 练习 1：基础镜像和命令使用
# 
# 要求：
# 1. 使用 ubuntu:22.04 作为基础镜像
# 2. 安装 nginx 和 curl 包
# 3. 创建一个简单的 HTML 文件，内容为 "Hello Docker!"
# 4. 将 HTML 文件复制到 nginx 的默认网站目录
# 5. 暴露 80 端口
# 6. 启动 nginx 服务
#
# 提示：
# - 使用 apt-get update 和 apt-get install 安装软件包
# - nginx 的默认网站目录是 /var/www/html/
# - 使用 CMD 或 ENTRYPOINT 启动 nginx
#
# 完成这个 Dockerfile 后，构建镜像并运行容器，访问 http://localhost:8080 应该能看到 "Hello Docker!" 页面

FROM ubuntu:22.04

# 在这里编写你的 Dockerfile 指令

# 更新软件源并安装相关软件
RUN apt-get update && \
	apt-get install -y curl nginx &&\
    rm -rf /var/lib/apt/lists/*

RUN echo "Hello Docker!" > /var/www/html/index.html

EXPOSE 80

# 相当于 RUN nginx -g daemon off
CMD ["nginx", "-g", "daemon off;"]

# 测试命令：
# docker build -t exercise1 .
# docker run -d -p 8080:80 exercise1 
# curl http://127.0.0.1:8080 | grep -q "Hello Docker"