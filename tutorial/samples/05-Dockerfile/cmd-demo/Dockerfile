FROM alpine:latest

# 创建一个简单的脚本
RUN echo '#!/bin/sh' > /app.sh && \
    echo 'echo "=== CMD 参数演示 ==="' >> /app.sh && \
    echo 'echo "参数个数: $#"' >> /app.sh && \
    echo 'echo "参数列表:"' >> /app.sh && \
    echo 'for arg in "$@"; do echo "  - $arg"; done' >> /app.sh && \
    chmod +x /app.sh

# CMD 指令格式: CMD ["可执行文件", "param1", "param2", ...]
# param1, param2 等是传递给可执行文件的参数
CMD ["/app.sh", "hello", "world", "docker"]
