FROM alpine:latest

# 创建一个简单的脚本
RUN echo '#!/bin/sh' > /entry.sh && \
    echo 'echo "=== ENTRYPOINT 参数演示 ==="' >> /entry.sh && \
    echo 'echo "脚本名: $0"' >> /entry.sh && \
    echo 'echo "参数个数: $#"' >> /entry.sh && \
    echo 'echo "参数列表:"' >> /entry.sh && \
    echo 'for arg in "$@"; do echo "  - $arg"; done' >> /entry.sh && \
    chmod +x /entry.sh

# ENTRYPOINT: 容器启动时执行的命令，不可被 docker run 覆盖
# CMD: 作为 ENTRYPOINT 的默认参数，可被 docker run 覆盖
ENTRYPOINT ["/entry.sh"]
CMD ["default", "args"]
