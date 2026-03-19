## embedded-env

```shell
# --no-cache 可以不使用缓存
docker build -f dev-env/embedded/Dockerfile -t docker.cnb.cool/sumu.k/docker-learning/embedded-env:latest .
docker images
docker run -it docker.cnb.cool/sumu.k/docker-learning/embedded-env:latest bash
docker push docker.cnb.cool/sumu.k/docker-learning/embedded-env:latest

docker run -it -p 8000:8000 --entrypoint "code-server" -d docker.cnb.cool/sumu.k/docker-learning/embedded-env:latest --bind-addr=0.0.0.0:8000 --auth=none
```

【gcc版本说明】
ubuntu 22.04编译4.19.71版本内核会报错，这里安装gcc-9，但是安装cmake的时候顺带会安装gcc-11，此时系统默认的gcc为gcc-11,编译内核的时候可以手动指定gcc-9，例如：

```shell
bear -- make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- HOSTCC=gcc-9 HOSTCXX=g++-9 all -j8
```
