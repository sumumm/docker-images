FROM ubuntu:24.04

LABEL maintainer=sumu

# 更新软件源并安装软件包
RUN sed -Ei "s@(security|ports|archive).ubuntu.com@mirrors.cloud.tencent.com@g" /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update && \
    apt-get install -y curl wget unzip git openssh-server vim zsh jq && \
    apt-get install -y gcc make cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

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

# zsh终端安装与配置(code-server 默认使用 zsh 终端)
COPY common/scripts ./scripts
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    chmod +x ./scripts/*.sh && \
    ./scripts/add-zsh-plugins.sh zsh-autosuggestions zsh-syntax-highlighting && \
    ./scripts/set-zsh-env.sh && \
    ./scripts/set-zsh-theme.sh risto && \
    echo 'setopt NO_AUTO_REMOVE_SLASH' >> /root/.zshrc && \
    mkdir -p ~/.oh-my-zsh/completions && \
    chsh -s $(which zsh)

# 生成code server中文插件必要的配置文件
RUN chmod +x ./scripts/create_languagepacks.sh && \
    bash ./scripts/create_languagepacks.sh && \
    rm -f ./scripts/create_languagepacks.sh

# 在最开始 source /etc/profile 
RUN sed -i '1isetopt NULL_GLOB 2>/dev/null\n\
source /etc/profile\n\
unsetopt NULL_GLOB 2>/dev/null\n\
if command -v docker > /dev/null; then\n\
    docker completion zsh > ~/.oh-my-zsh/completions/_docker\n\
fi' $HOME/.zshrc

COPY common/settings.json /root/.vscode-server/data/Machine/settings.json
COPY common/settings.json /root/.local/share/code-server/Machine/settings.json
COPY common/gitconfig /root/.gitconfig

# 指定字符集支持命令行输入中文（根据需要选择字符集）
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

