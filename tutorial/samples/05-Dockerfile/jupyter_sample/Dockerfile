FROM python:3.10-slim

# 安装系统依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 包
RUN pip install --no-cache-dir \
    jupyterlab==4.4.3 \
    pandas==2.3.0 \
    numpy==1.26.2 \
    matplotlib==3.8.2

# 安装 Jupyter 内核
RUN pip install --no-cache-dir \
    ipykernel==6.29.0 \
    && python -m ipykernel install --name python3

# 设置工作目录并初始化笔记本
WORKDIR /notebooks
COPY sample-notebook.ipynb .

# 暴露 Jupyter 端口
EXPOSE 8888

# 启动命令
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.disable_check_xsrf=True"]
