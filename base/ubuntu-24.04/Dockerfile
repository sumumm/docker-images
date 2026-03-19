FROM ubuntu:24.04

LABEL maintainer=sumu
LABEL basic_images=ubuntu:24.04

# 指定字符集支持命令行输入中文（根据需要选择字符集）
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

# 更新软件源并安装基础软件包
RUN sed -Ei "s@(security|ports|archive).ubuntu.com@mirrors.cloud.tencent.com@g" /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update && \
    apt-get install -y curl wget unzip git openssh-server vim jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# 拷贝 common/scripts 脚本到镜像的 /scripts
COPY common/scripts /scripts

# 配置bash并设置默认终端为bash
RUN curl -fsSL -o ~/.git-prompt.bash https://cnb.cool/sumu.k/ohmybash/-/git/raw/main/git-prompt.bash && \
    curl -fsSL -o ~/.git-completion.bash https://cnb.cool/sumu.k/ohmybash/-/git/raw/main/git-completion.bash && \
    chmod +x ~/.git-prompt.bash ~/.git-completion.bash /scripts/set-bash-env.sh && \
    /scripts/set-bash-env.sh && \
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

# 拷贝Git相关文件
COPY common/gitconfig /root/.gitconfig

# 清理拷贝过来的脚本文件
RUN rm -rf /scripts
