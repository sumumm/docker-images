## node-env

### 添加 nodejs 源

```shell
# NodeSource 仓库的机制是：setup_24.x 脚本配置的仓库中只包含 Node.js 24.x 系列的最新版本。
curl -sL https://rpm.nodesource.com/setup_24.x | bash -
```

- `curl -sL`： 这是一个使用 curl 命令的部分，-s 参数表示静默模式，不输出进度信息，而 -L 参数表示跟随重定向。这样可以从给定的 URL 下载脚本。
- `https://deb.nodesource.com/setup_24.x`： 这是 NodeSource 提供的一个脚本地址，用于设置 Node.js 的源。setup_24.x 表示要安装 Node.js 版本 24.x，可以根据需要更改版本号。
- `|`： 这是管道操作符，将前一个命令的输出传递给下一个命令。
- `bash -`： 则表示以 Bash Shell 运行脚本。

Github：[nodesource/distributions](https://github.com/nodesource/distributions)

### 查看可用软件版本

```shell
apt list -a nodejs       # 列出软件包所有可用版本（包括已安装的和其他版本的）
apt-cache policy nodejs  # 查看版本及其优先级信息
apt-cache madison nodejs # 以表格形式查看可用版本
```

### 构建镜像

```shell
# 构建镜像
docker build -f dev-env/node/Dockerfile -t docker.cnb.cool/sumu.k/docker-learning/node-env:latest .

# 查看镜像
docker images

# 运行镜像
docker run -it -p 8000:8000 docker.cnb.cool/sumu.k/docker-learning/node-env:latest \
  sh -c "code-server --bind-addr=0.0.0.0:8000 --auth=none & exec zsh"

# 推送镜像
docker push docker.cnb.cool/sumu.k/docker-learning/node-env:latest
```

> 说明：安装 nodejs的时候执行了 apt-get install -y nodejs，这条命令同时安装了Python 3.11.2，但是没有安装pip
