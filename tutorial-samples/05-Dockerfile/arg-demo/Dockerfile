FROM alpine:latest

# ARG 指令：定义构建时参数
# 格式: ARG <name>[=<default value>]

# 带默认值的 ARG
ARG APP_VERSION=1.0.0
ARG BUILD_BY=developer

# 不带默认值的 ARG（必须在构建时提供）
ARG BUILD_DATE

# ARG 只在构建时有效，不会保留在镜像中
# 如需在运行时使用，需配合 ENV
ENV APP_VERSION=${APP_VERSION} \
    BUILD_BY=${BUILD_BY} \
    BUILD_DATE=${BUILD_DATE}

# 创建脚本显示信息
RUN echo '#!/bin/sh' > /info.sh && \
    echo 'echo "=== ARG 构建参数演示 ==="' >> /info.sh && \
    echo 'echo "APP_VERSION: $APP_VERSION"' >> /info.sh && \
    echo 'echo "BUILD_BY: $BUILD_BY"' >> /info.sh && \
    echo 'echo "BUILD_DATE: $BUILD_DATE"' >> /info.sh && \
    chmod +x /info.sh

CMD ["sh", "/info.sh"]
