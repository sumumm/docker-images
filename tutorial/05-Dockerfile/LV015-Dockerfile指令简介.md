# Dockerfile 指令

## 一、核心构建指令

|    指令    |                说明                 |            示例             |
| :--------: | :---------------------------------: | :-------------------------: |
|    FROM    |   指定基础镜像，必须是第一条指令    |     `FROM ubuntu:20.04`     |
|  WORKDIR   | 设置工作目录，后续指令在此目录执行  |       `WORKDIR /app`        |
|    COPY    |        复制文件/目录到镜像中        |        `COPY . /app`        |
|    ADD     | 复制文件到镜像中，支持 URL 和自动解压 |    `ADD app.tar.gz /app`    |
|    RUN     |          在构建时执行命令           |    `RUN apt-get update`     |
|    CMD     |        容器启动时的默认命令         | `CMD ["python", "app.py"]`  |
| ENTRYPOINT |   容器启动时的入口点，不会被覆盖    | `ENTRYPOINT ["./start.sh"]` |
| USER | 指定执行后续命令的用户和用户组 | `USER root` |

Docker 按顺序执行 Dockerfile 中的指令。Dockerfile **必须以 `FROM` 指令开头**。这可能位于 [解析器指令](https://docs.docker.com/reference/dockerfile/#parser-directives)、[注释](https://docs.docker.com/reference/dockerfile/#format) 和全局作用域的 [ARG](https://docs.docker.com/reference/dockerfile/#arg) 之后。`FROM` 指令指定了我们正在构建所基于的 [基础镜像](https://docs.docker.com/glossary/#base-image)。`FROM` 之前只能有一个或多个 `ARG` 指令，这些指令声明了在 Dockerfile 的 FROM 行中使用的参数。

> BuildKit 将以 `#` 开头的行视为注释，除非该行是有效的 [解析器指令](https://docs.docker.com/reference/dockerfile/#parser-directives)。行中其他任何位置的 `#` 标记都被视为参数。

### 1. FROM

#### 1.1 指令说明

这个指令是指定我们要使用的基础镜像，例如 ubuntu: 22.04、alpine: latest 等。FROM 指令支持以下几种格式：

```dockerfile
FROM <image>
FROM <image>:<tag>
FROM <image>@<digest>
```

一个 Dockerfile 中可以有多个 `FROM` 指令，这是完全合法的。这种用法叫做 **多阶段构建（Multi-stage Build）**，多阶段构建搭配 `AS` 使用，`AS` 后为此阶段的名称，方便后面引用。当有多个 FROM 的时候，最终的镜像只包含 **最后一个 FROM 阶段** 的内容。

```dockerfile
# 第一阶段：构建阶段
FROM ubuntu:latest AS builder
WORKDIR /app
COPY hello.txt .

# 第二阶段：运行阶段
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello.txt .
```

这里可以准备一个 hello.txt 文档，里面随便写点东西即可。

#### 1.2 使用示例

对应示例为: [Dockerfile](../samples/05-Dockerfile/multi-stage/Dockerfile)，使用如下命令打包和运行：

```shell
docker build -t from-multi-stage .
docker run -it from-multi-stage bash
```

### 2. WORKDIR

WORKDIR 用于指定工作目录。用 WORKDIR 指定的工作目录，会在构建镜像的每一层中都存在。以后各层的当前目录就被改为指定的目录，如该目录不存在，WORKDIR 会帮我们建立目录。

docker build 构建镜像过程中的，每一个 RUN 命令都是新建的一层。只有通过 WORKDIR 创建的目录才会一直存在。一般格式：

```dockerfile
WORKDIR <工作目录路径>
```

> Tips：影响后续的 RUN、CMD、ENTRYPOINT、COPY 和 ADD 指令。

### 3. COPY

#### 3.1 指令说明

复制指令，从上下文目录中复制文件或者目录到容器里指定路径。一般格式：

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

- **`[--chown = <user>: <group>]`**：可选参数，用户改变复制到容器内文件的拥有者和属组。

- **`<src>`**：源文件或者源目录，这里可以是通配符表达式，其通配符规则要满足 Go 的 filepath.Match 规则。例如：

```dockerfile
COPY hom* /mydir/
COPY hom?.txt /mydir/
```

- **`<dest>`**：容器内的指定路径，该路径不用事先建好，路径不存在的话，会自动创建。

#### 3.2 使用示例

### 4. ADD

#### 4.1 指令说明

ADD 指令和 COPY 的使用格类似（同样需求下，官方推荐使用 COPY）。功能也类似，不同之处如下：

- ADD 的优点：在执行 `<src>` 为 tar 压缩文件的话，压缩格式为 gzip, bzip2 以及 xz 的情况下，会自动复制并解压到 `<dest>`。
- ADD 的缺点：在不解压的前提下，无法复制 tar 压缩文件。会令镜像构建缓存失效，从而可能会令镜像构建变得比较缓慢。具体是否使用，可以根据是否需要自动解压来决定。

#### 4.2 使用示例

暂无。

### 5. RUN

在当前镜像之上执行命令并创建新的镜像层。每个 RUN 指令都会创建一个新的镜像层。RUN 指令支持 shell 格式和 exec 格式：

```dockerfile
# Shell 格式
RUN command

# Exec 格式
RUN ["executable", "param1", "param2"]
```

### 6. CMD

#### 6.1 指令说明

CMD 为启动的容器指定默认要运行的程序，程序运行结束，容器也就结束。CMD 指令指定的程序可被 docker run 命令行参数中指定要运行的程序所覆盖。

> **注意**：如果 Dockerfile 中如果存在多个 CMD 指令，仅最后一个生效。

一般格式如下：

```dockerfile
# Shell 格式
CMD <shell 命令> 

# Exec 格式
CMD ["<可执行文件或命令>","<param1>","<param2>",...] 

# 该写法是为 ENTRYPOINT 指令指定的程序提供默认参数
CMD ["<param1>","<param2>",...]   
```

推荐使用第二种格式，执行过程比较明确。第一种格式实际上在运行的过程中也会自动转换成第二种格式运行，并且默认可执行文件是 sh。

> Tips：CMD 类似于 RUN 指令，用于运行程序，但二者运行的时间点不同：
>
> - CMD 在 docker run 时运行。
>
> - RUN 是在 docker build。

#### 6.2 使用示例

暂无。

### 7. ENTRYPOINT

#### 7.1 指令说明

类似于 CMD 指令，但其不会被 docker run 的命令行参数指定的指令所覆盖，而且这些命令行参数会被当作参数送给 ENTRYPOINT 指令指定的程序。

但是, 如果运行 docker run 时使用了 --entrypoint 选项，将覆盖 ENTRYPOINT 指令指定的程序。该指令在执行 docker run 的时候可以指定 ENTRYPOINT 运行所需的参数。如果 Dockerfile 中如果存在多个 ENTRYPOINT 指令，仅最后一个生效。

指令一般格式如下

```dockerfile
# Exec 格式（推荐）
ENTRYPOINT ["executable", "param1", "param2"]

# Shell 格式
ENTRYPOINT command param1 param2
```

可以搭配 CMD 命令使用：一般是变参才会使用 CMD ，这里的 CMD 等于是在给 ENTRYPOINT 传参，以下示例会提到。

#### 7.2 使用示例

假设已通过 Dockerfile 构建了 nginx: test 镜像：

```dockerfile
FROM nginx

# 定参
ENTRYPOINT ["nginx", "-c"] 
# 变参 
CMD ["/etc/nginx/nginx.conf"] 
```

- （1）不传参运行

```shell
docker run  nginx:test
```

容器内会默认运行以下命令，启动主进程。

```shell
nginx -c /etc/nginx/nginx.conf
```

- （2）传参运行

```shell
docker run  nginx:test -c /etc/nginx/new.conf
```

容器内会默认运行以下命令，启动主进程(/etc/nginx/new.conf: 假设容器内已有此文件)

```shell
nginx -c /etc/nginx/new.conf
```

### 8. USER

#### 8.1 指令说明

用于指定执行后续命令的用户和用户组，这边只是切换后续命令执行的用户（用户和用户组必须提前已经存在）。

```dockerfile
USER <用户名>[:<用户组>]
```

#### 8.2 使用示例

暂无。

## 二、网络和存储指令

|  指令  |        说明        |        示例        |
| :----: | :----------------: | :----------------: |
| EXPOSE | 声明容器监听的端口 |   `EXPOSE 8080`    |
| VOLUME |     创建挂载点     | `VOLUME ["/data"]` |

### 1. EXPOSE

#### 1.1 指令说明

仅仅只是声明端口。作用如下：

- 帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射。
- 在运行时使用随机端口映射时，也就是 docker run -P 时，会自动随机映射 EXPOSE 的端口。

```dockerfile
EXPOSE <端口1> [<端口2>...]
```

#### 1.2 使用示例

暂无。

### 2. VOLUME

定义匿名数据卷。在启动容器时忘记挂载数据卷，会自动挂载到匿名卷。作用如下

- 避免重要的数据，因容器重启而丢失，这是非常致命的。
- 避免容器不断变大。

```dockerfile
VOLUME ["<路径1>", "<路径2>"...]
VOLUME <路径>
```

在启动容器 docker run 的时候，我们可以通过 -v 参数修改挂载点。

#### 2.2 使用示例

后续会详细再学习。

## 三、环境配置指令

| 指令 |      说明      |           示例            |
| :--: | :------------: | :-----------------------: |
| ENV  |  设置环境变量  | `ENV NODE_ENV=production` |
| ARG  | 定义构建时参数 |     `ARG VERSION=1.0`     |

### 1. ENV

#### 1.1 指令说明

设置环境变量，定义了环境变量，那么这些变量在构建过程中和容器运行时都可用。一般格式：

```dockerfile
ENV <key> <value>
ENV <key1>=<value1> <key2>=<value2>...
```

#### 1.2 使用示例

以下示例设置 NODE_VERSION = 7.2.0 ， 在后续的指令中可以通过 `$NODE_VERSION` 引用：

```dockerfile
ENV NODE_VERSION 7.2.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
```

### 2. ARG

#### 2.1 指令说明

构建参数，与 ENV 作用一致。不过作用域不一样。ARG 设置的环境变量仅对 Dockerfile 内有效，也就是说只有 docker build 的过程中有效，构建好的镜像内不存在此环境变量。即 **这些参数只在构建过程中可用，容器运行时不可用**。

构建命令 docker build 中可以用 `--build-arg <参数名>=<值>` 来覆盖。一般格式：

```dockerfile
ARG <参数名>[=<默认值>]
```

#### 2.2 使用示例

暂无。

## 四、元数据和高级指令

|  指令   |              说明              |         示例          |
| :-----: | :----------------------------: | :-------------------: |
|  LABEL  |         添加镜像元数据         | `LABEL version="1.0"` |
| ONBUILD | 当镜像作为基础镜像时触发的指令 | `ONBUILD COPY . /app` |

### 1. LABEL

#### 1.1 指令说明

LABEL 指令用来给镜像添加一些元数据（metadata）比如维护者信息、版本信息等。形式为键值对，语法格式如下：

```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

#### 1.2 使用示例

比如我们可以添加镜像的作者：

```dockerfile
LABEL org.opencontainers.image.authors="sumu"
```

### 2. ONBUILD

#### 2.1 指令说明

用于延迟构建命令的执行。简单的说，就是 Dockerfile 里用 ONBUILD 指定的命令，在本次构建镜像的过程中不会执行（假设镜像为 test-build）。当有新的 Dockerfile 使用了之前构建的镜像 FROM test-build ，这时执行新镜像的 Dockerfile 构建时候，会执行 test-build 的 Dockerfile 里的 ONBUILD 指定的命令。

```dockerfile
ONBUILD <其它指令>
```

#### 2.2 使用示例

## 五、健康检查和 Shell 指令

|    指令     |       说明       |                    示例                     |
| :---------: | :--------------: | :-----------------------------------------: |
| HEALTHCHECK | 定义容器健康检查 | `HEALTHCHECK CMD curl -f http://localhost/` |
|    SHELL    |  指定默认 shell   |         `SHELL ["/bin/bash", "-c"]`         |

### 1. HEALTHCHECK

#### 1.1 指令说明

用于指定某个程序或者指令来监控 docker 容器服务的运行状态。

```dockerfile
HEALTHCHECK [选项] CMD <命令>：设置检查容器健康状况的命令
HEALTHCHECK NONE：如果基础镜像有健康检查指令，使用这行可以屏蔽掉其健康检查指令

HEALTHCHECK [选项] CMD <命令> : 这边 CMD 后面跟随的命令使用，可以参考 CMD 的用法。
```

#### 1.2 使用示例

暂无。

> 参考资料：
>
> [Dockerfile 参考 - Dockerfile 指令详解 | Docker 中文文档](https://dockerdocs.xuanyuan.me/reference/dockerfile)
>
> [Docker Dockerfile | 菜鸟教程](https://www.runoob.com/docker/docker-dockerfile.html)
