FROM alpine:latest

# ENV 指令：设置环境变量
# 格式: ENV <key>=<value>

# 单个环境变量
ENV APP_NAME=myapp
ENV APP_VERSION=1.0.0

# 多个环境变量（推荐写法）
ENV DB_HOST=localhost \
    DB_PORT=5432 \
    DB_USER=admin

# 环境变量可以在后续指令中使用
ENV APP_DIR=/opt/app
RUN mkdir -p $APP_DIR && \
    echo "#!/bin/sh" > $APP_DIR/start.sh && \
    echo 'echo "=== ENV 环境变量演示 ==="' >> $APP_DIR/start.sh && \
    echo 'echo "APP_NAME: $APP_NAME"' >> $APP_DIR/start.sh && \
    echo 'echo "APP_VERSION: $APP_VERSION"' >> $APP_DIR/start.sh && \
    echo 'echo "APP_DIR: $APP_DIR"' >> $APP_DIR/start.sh && \
    echo 'echo "DB_HOST: $DB_HOST"' >> $APP_DIR/start.sh && \
    echo 'echo "DB_PORT: $DB_PORT"' >> $APP_DIR/start.sh && \
    echo 'echo "DB_USER: $DB_USER"' >> $APP_DIR/start.sh && \
    chmod +x $APP_DIR/start.sh

CMD ["sh", "/opt/app/start.sh"]
