FROM nginx:alpine

# 安装 curl
RUN apk update && apk add --no-cache curl

# 保留原始镜像的默认配置
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]