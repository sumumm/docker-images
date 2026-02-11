# Docker 学习文档

## 一、Docker安装与卸载

>参考资料：[在 Ubuntu 上安装 Docker Engine](https://docker.cadn.net.cn/manuals/engine_install_ubuntu)、[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

### 1. 卸载冲突的包

运行以下命令以卸载所有冲突的软件包：

```shell
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
```

### 2. 使用脚本安装

这个可以参考：[docker/docker-install: Docker installation script](https://github.com/docker/docker-install)，我们执行下面的命令自动安装：

```shell
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### 3. [卸载 Docker Engine](https://docker.cadn.net.cn/manuals/engine_install_ubuntu#uninstall-docker-engine)

（1）卸载 Docker Engine、CLI、containerd 和 Docker Compose 软件包：

```shell
 sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```

（2）主机上的镜像、容器、卷或自定义配置文件 不会自动删除。要删除所有镜像、容器和卷，请执行以下作：

```shell
 sudo rm -rf /var/lib/docker
 sudo rm -rf /var/lib/containerd
```

（3）删除源列表和密钥环

```shell
 sudo rm /etc/apt/sources.list.d/docker.list
 sudo rm /etc/apt/keyrings/docker.asc
```

必须手动删除任何已编辑的配置文件。
