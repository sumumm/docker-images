FROM ubuntu:24.04

LABEL maintainer=sumu
LABEL basic_images=ubuntu:24.04

# 指定字符集、设置时区、避免交互式提示等
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

# 更新软件源并安装基础软件包
RUN sed -Ei "s@(security|ports|archive).ubuntu.com@mirrors.cloud.tencent.com@g" /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update && \
    apt-get install -y curl wget unzip git openssh-server vim jq sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# 拷贝 common/scripts 脚本到镜像的 /scripts
COPY common/scripts /scripts
# 拷贝Git相关文件
COPY common/gitconfig /root/.gitconfig

# 配置bash并设置默认终端为bash（使用全局配置，所有用户共享）
RUN mkdir -p /usr/local/share/bash && \
    curl -fsSL -o /usr/local/share/bash/git-prompt.bash https://cnb.cool/sumu.k/ohmybash/-/git/raw/main/git-prompt.bash && \
    curl -fsSL -o /usr/local/share/bash/git-completion.bash https://cnb.cool/sumu.k/ohmybash/-/git/raw/main/git-completion.bash && \
    chmod +x /usr/local/share/bash/git-prompt.bash /usr/local/share/bash/git-completion.bash /scripts/set-global-bash-env.sh && \
    /scripts/set-global-bash-env.sh && \
    chsh -s $(which bash)

# install vscode and extension
RUN curl -fsSL https://code-server.dev/install.sh | sh &&\
    code-server --install-extension cnbcool.cnb-welcome &&\
    code-server --install-extension ms-ceintl.vscode-language-pack-zh-hans &&\
    code-server --install-extension redhat.vscode-yaml &&\
    code-server --install-extension cloudstudio.live-server &&\
    code-server --install-extension tencent-cloud.coding-copilot &&\
    code-server --install-extension PKief.material-icon-theme &&\
    code-server --install-extension github.github-vscode-theme &&\
    code-server --install-extension EditorConfig.EditorConfig

# 生成code server中文插件必要的配置文件
RUN chmod +x /scripts/create_languagepacks.sh && \
    bash /scripts/create_languagepacks.sh && \
    rm -f /scripts/create_languagepacks.sh

# 拷贝vscode配置文件
COPY common/bash-env-settings.template /root/.vscode-server/data/Machine/settings.json
COPY common/bash-env-settings.template /root/.local/share/code-server/Machine/settings.json

# 创建用户 sumu,此时系统将会有三个用户 root、sumu、ubuntu(ubuntu24.04会自动创建)
RUN useradd -m -s /bin/bash sumu && \
    echo "sumu:000000" | chpasswd && \
    passwd -u root && \
    echo "root:000000" | chpasswd && \
    usermod -aG sudo sumu

# 清理拷贝过来的脚本文件
RUN rm -rf /scripts
