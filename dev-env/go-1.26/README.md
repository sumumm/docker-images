## 一、go 环境安装

### 1. gvm 管理 go

#### 1.1 gvm是什么？

GVM 提供了一个用于管理 Go 版本的接口。Github 仓库是：[moovweb/gvm](https://github.com/moovweb/gvm)

#### 1.2 怎么安装？

##### 1.2.1 安装命令

```shell
sudo apt-get -y install bison bsdextrautils build-essential
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /root/.gvm/scripts/gvm
```

- bsdextrautils 包含 hexdump 工具，若不安装，则会报错：

```shell
ERROR: GVM couldn't find hexdump
```

- build-essential 包含一些依赖，若未安装，会有以下报错：

```shell
ERROR: Missing requirements.
```

##### 1.2.2 dockerfile写法

安装 gvm 的话 dockerfile 中可以这样写（这里直接加了go和相关工具的安装）：

```dockerfile
# gvm 安装脚本是 bash 脚本，所以这里需要使用bash
SHELL ["/bin/bash", "-c"]
RUN bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) &&\
    source ~/.bashrc && gvm install ${GO_VERSION} -B && gvm use ${GO_VERSION} --default &&\
    go install -v golang.org/x/tools/gopls@latest
    
# 或者
# gvm 安装脚本是 bash 脚本，所以这里需要使用 bash
RUN ["/bin/bash", "-c", "bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) &&\
    source ~/.bashrc && gvm install ${GO_VERSION} -B && gvm use ${GO_VERSION} --default &&\
    go install -v golang.org/x/tools/gopls@latest"]
```

这里主要原因是 `/bin/sh`（Docker 默认 shell）不支持 bash 的进程替换语法 `<(...)`。 

#### 1.3 安装 go

```shell
# gvm go<version> -B # -B表示使用预编译二进制文件，跳过编译步骤
gvm install go1.26.1 -B
gvm use go1.26.1 --default
go version
```

若安装成功，查看版本会有如下打印信息：

```shell
➜  /workspace git:(main) ✗ go version  
go version go1.26.1 linux/amd64
```

一个不加 -B 参数的问题：

```shell
➜  /workspace git:(main) ✗ gvm install go1.26.1
Downloading Go source...
Installing go1.26.1...
 * Compiling...
/root/.gvm/scripts/install: line 93: go: command not found
ERROR: Failed to compile. Check the logs at /root/.gvm/logs/go-go1.26.1-compile.log
ERROR: Failed to use installed version
```

可以看到 gvm 其实是从源码编译 Go ，这个时候需要 go 命令来编译 bootstrap 版本，Bootstrap 版本是用于编译 Go 自身的 "种子" 版本。Go 使用自举编译技术：编译 Go 需要 Go 本身，Bootstrap 版本是一个预编译的、稳定的 Go 版本，用它来编译新版本的 Go。

我们可以加上 -B 参数来直接使用预编译的二进制文件。


#### 1.4 GOPATH

GOPATH 是 Go 的工作目录路径, 用于存储 Go 代码和依赖。可以通过下面的命令查看路径：

```shell
go env GOPATH
```

通过 GVM 安装 Go 时, 一般不需要手动配置 GOPATH。它会自动为每个 Go 版本创建独立的 GOPATH:

```shell
➜  /workspace git:(main) ✗ tree /root/.gvm/pkgsets/
/root/.gvm/pkgsets/
└── go1.26.1
    └── global
        └── overlay
            ├── bin
            └── lib
                └── pkgconfig
```

通过 GVM 管理时，不需要手动配置, 但可以自定义:

```shell
# 如果需要自定义 GOPATH
export GOPATH=/root/go
```

在 Dockerfile 中可以这样写：

```dockerfile
ENV GOPATH=/root/go
ENV PATH="${PATH}:${GOPATH}/bin"
```

### 2. Hello World

#### 2.1 demo源码

安装完 go 了，我们写一个 HelloWorld 程序：

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello, World!")
}
```

#### 2.2 直接运行

```shell
go run main.go
```

#### 2.3 编译运行

```shell
go build -o hello main.go
./hello
```



### 3. 安装工具和依赖

#### 3.1 gopls 语言服务器

##### 3.1.1 怎么安装？

我们来安装一个工具一看一下，例如 gopls，它是 Go 官方的语言服务器协议(LSP)实现。它的说明文档在这里：[gopls/README.md](https://github.com/golang/tools/blob/master/gopls/README.md)

我们可以执行下面的命令来安装：

```shell
go install -v golang.org/x/tools/gopls@latest
# 安装到指定位置
#go install -o /usr/local/bin/gopls golang.org/x/tools/gopls@latest
gopls version # 查看版本
```

安装成功则会有以下打印信息：

```shell
➜  /workspace git:(main) ✗ gopls version
golang.org/x/tools/gopls v0.21.1
```

在 VS Code 中，VS Code 的 Go 插件会自动使用 gopls:

```json
{
  "go.useLanguageServer": true
}
```

##### 3.1.2 安装到哪里了？

`go install`安装的是可执行工具，默认安装在`$GOPATH/bin/`

```shell
# 查看工具位置
which gopls
# 或
whereis gopls

# 查看版本
gopls version
```

#### 3.2 项目依赖

##### 3.2.1 怎么安装？

go-cnb 是一个 Go client library 用于访问 CNB API。[cnb/sdk/go-cnb](https://cnb.cool/cnb/sdk/go-cnb/-/tree/master)

```shell
# 创建测试目录
mkdir go-demo
cd go-demo

# 初始化 go.mod (如果没有)
go mod init go-demo # go-demo是模块名，会出现在go.mod文件

go get cnb.cool/cnb/sdk/go-cnb
```

安装成功会有以下打印信息：

```shell
➜  go-demo git:(main) ✗ go get cnb.cool/cnb/sdk/go-cnb
go: downloading cnb.cool/cnb/sdk/go-cnb v1.18.8
go: added cnb.cool/cnb/sdk/go-cnb v1.18.8
```

##### 3.2.2 安装到了哪里？

`go get` 安装的依赖在`$GOPATH/pkg/mod/`中：

```bash
# 查看缓存位置
go env GOMODCACHE

# 默认位置
# $GOPATH/pkg/mod
# 例如：/root/go/pkg/mod
```

目录结构示例：

```shell
/root/go/
├── pkg/
│   └── mod/
│       └── cnb.cool/
│           └── cnb/
│               └── sdk/
│                   └── go-cnb@v1.18.8/   # 依赖源码缓存
└── bin/
    └── gopls                              # go install 安装的工具
```



## 二、Goproxy.cn

### 1. 简介

中国最可靠的 Go 模块代理。

Goproxy.cn 完全实现了 [GOPROXY 协议](https://go.dev/ref/mod#goproxy-protocol)。它是一个由中国备受信赖的云服务提供商 [七牛云](https://www.qiniu.com) 支持的非营利性项目。我们的目标是为中国的 Gopher 提供一个免费的、可靠的、持续在线且通过全球 CDN 加速的模块代理。请在 [status.goproxy.cn](https://status.goproxy.cn) 订阅我们的系统性能实时和历史数据。

Goproxy.cn 专注于服务在 [https://goproxy.cn](https://goproxy.cn) 的 Web 应用开发。如果你正在寻找一种简单的方法来搭建自己的 Go 模块代理，请查看 [Goproxy](https://github.com/goproxy/goproxy)，Goproxy.cn 就是基于它开发的。

### 2. 用法

在 Linux 下，打开我们的终端并执行

```shell
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

# 或者

echo "export GO111MODULE=on" >> ~/.profile
echo "export GOPROXY=https://goproxy.cn" >> ~/.profile
source ~/.profile
```
