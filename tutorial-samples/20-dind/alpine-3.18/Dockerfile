FROM alpine:3.18

LABEL maintainer=eryajf

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
    && apk upgrade \
    && apk add bash curl wget alpine-conf busybox-extras sqlite tzdata \
    && /sbin/setup-timezone -z Asia/Shanghai && apk del alpine-conf && rm -rf /var/cache/*

# docker build -t docker.cnb.cool/sumu.k/docker-learning/alpine-3.18 .
# docker push docker.cnb.cool/sumu.k/docker-learning/alpine-3.18
