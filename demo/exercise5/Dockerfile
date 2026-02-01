# 作业目标：
# 构建一个 Python Web 应用镜像，支持通过 Redis 计数。
#
# 关键步骤说明：
# - 选择合适的 Python 基础镜像
# - 安装依赖（如 flask、redis）
# - 拷贝应用代码到镜像中
# - 设置容器启动命令

FROM python:3.10-slim
# 在这里编写你的 Dockerfile
# 设置工作目录
WORKDIR /app
# 拷贝依赖文件并安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# 拷贝应用代码
COPY app.py .
# 声明容器对外服务端口
EXPOSE 5000
# 设置容器启动命令
CMD ["python", "app.py"]
