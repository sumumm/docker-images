# 练习 2：Python 应用构建
#
# 要求：
# 1. 创建一个简单的 Python Flask 应用的 Dockerfile
# 2. 实现以下功能：
#    - 使用 python:3.11-slim 作为基础镜像
#    - 安装应用依赖
#    - 创建非 root 用户运行应用
#    - 配置工作目录
#    - 设置环境变量
#    - 暴露应用端口
#
# 提示：
# - 使用 requirements.txt 管理依赖
# - 使用 WORKDIR 设置工作目录
# - 使用 USER 指令切换用户
# - 使用 ENV 设置环境变量
#
# 测试命令：
# docker build -t exercise2 .
# docker run -d -p 5000:5000 exercise2
# curl http://127.0.0.1:5000 | grep -q "Hello Docker"

# 在这里编写你的 Dockerfile 指令

# 使用官方Python 3.11的slim版本作为基础镜像，slim版本比完整版更轻量，适合生产环境
FROM python:3.11-slim

# 设置环境变量
# PYTHONUNBUFFERED=1: 让Python不缓冲标准输出/错误，确保日志实时显示
# PYTHONDONTWRITEBYTECODE=1: 防止Python创建.pyc文件，减少容器体积
# FLASK_APP=app.py: 指定Flask应用入口文件
# FLASK_RUN_HOST=0.0.0.0: 允许Flask服务接受来自任何IP地址的连接
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FLASK_APP=app.py \
    FLASK_RUN_HOST=0.0.0.0

# 设置工作目录为/app，后续命令都在此目录下执行
WORKDIR /app

# 创建非root用户以增强安全性
# -m: 表示在创建用户的同时，为用户创建家目录（home directory）。通常家目录位于/home/下，目录名与用户名相同。
# -u 1000: 指定用户ID (UID)：强制设置用户的UID为1000，通常UID 1000是系统中第一个普通用户的默认ID
# appuser: 用户名
# chown -R appuser:appuser /app: 将/app目录的所有权更改为appuser
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# 将requirements.txt复制到容器的工作目录/app
COPY requirements.txt .

# 安装Python依赖
# --no-cache-dir: 不缓存下载的包，减小镜像大小
# -r requirements.txt: 从requirements.txt文件安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 将应用代码复制到工作目录
# 这里复制app.py（Flask应用主文件）
COPY app.py .

# 切换到非root用户appuser，降低权限以提高安全性
USER appuser

# 暴露容器端口5000（Flask默认端口）
EXPOSE 5000

# 容器启动时执行的命令
# 使用Flask内置开发服务器运行应用，注意：生产环境建议使用Gunicorn等WSGI服务器
CMD ["flask", "run"]
