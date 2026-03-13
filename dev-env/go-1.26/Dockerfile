FROM debian:bookworm

LABEL maintainer=sumu

ARG GO_VERSION=go1.26.1

# 系统消息为英文，但仍支持 UTF-8 字符编码、设置时区、避免交互式提示等
ENV TZ=Asia/Shanghai
ENV LC_ALL=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

ENV GOPATH=/root/go
ENV PATH="${PATH}:${GOPATH}/bin"
ENV GOPROXY="https://goproxy.cn,direct"


# 修改软件源并更新软件包
RUN apt-get update && \
    apt-get install -y curl wget unzip git openssh-server vim zsh &&\
    apt-get install -y bsdextrautils bison build-essential

# gvm 安装脚本是 bash 脚本，所以这里需要使用 bash
RUN ["/bin/bash", "-c", "bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) &&\
    source ~/.bashrc && gvm install ${GO_VERSION} -B && gvm use ${GO_VERSION} --default &&\
    go install -v golang.org/x/tools/gopls@latest"]

# install vscode and extension
RUN curl -fsSL https://code-server.dev/install.sh | sh &&\
    code-server --install-extension cnbcool.cnb-welcome &&\
    code-server --install-extension redhat.vscode-yaml &&\
    code-server --install-extension cloudstudio.live-server &&\
    code-server --install-extension tencent-cloud.coding-copilot &&\
    code-server --install-extension PKief.material-icon-theme &&\
    code-server --install-extension github.github-vscode-theme &&\
    code-server --install-extension EditorConfig.EditorConfig &&\
    code-server --install-extension golang.go

# zsh终端安装与配置(code-server 默认使用 zsh 终端)
COPY ../../common/scripts ./scripts
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    chmod +x ./scripts/*.sh && \
    ./scripts/add-zsh-plugins.sh zsh-autosuggestions zsh-syntax-highlighting && \
    ./scripts/set-zsh-env.sh && \
    echo 'setopt NO_AUTO_REMOVE_SLASH' >> /root/.zshrc && \
    echo '[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"' >> /root/.zshrc && \
    mkdir -p ~/.oh-my-zsh/completions && \
    chsh -s $(which zsh)

# 在最开始 source /etc/profile 
RUN sed -i '1isetopt NULL_GLOB 2>/dev/null\n\
source /etc/profile\n\
unsetopt NULL_GLOB 2>/dev/null\n\
' $HOME/.zshrc

COPY ../../common/settings.json /root/.vscode-server/data/Machine/settings.json
COPY ../../common/settings.json /root/.local/share/code-server/Machine/settings.json
COPY ../../common/gitconfig /root/.gitconfig

ENV PATH=/root/.gvm/pkgsets/${GO_VERSION}/global/bin:/root/.gvm/gos/${GO_VERSION}/bin:/root/.gvm/pkgsets/${GO_VERSION}/global/overlay/bin:$PATH
