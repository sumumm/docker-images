FROM ubuntu:22.04

LABEL maintainer=sumu
LABEL basic_images=ubuntu:22.04

# 指定字符集、设置时区、避免交互式提示等
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

# 更新软件源并安装基础软件包
RUN sed -Ei "s@(security|ports|archive).ubuntu.com@mirrors.cloud.tencent.com@g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y curl wget unzip git openssh-server vim jq sudo bash-completion && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# 拷贝相关文件, 拷贝 common 所有文件到镜像的 /common
COPY common /common

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

# vscode配置
RUN chmod +x /common/scripts/create_languagepacks.sh && \
    bash /common/scripts/create_languagepacks.sh && \
    mkdir -p /root/.vscode-server/data/Machine /root/.local/share/code-server/Machine && \
    cp -f /common/settings.json /root/.vscode-server/data/Machine/settings.json && \
    cp -f /common/settings.json /root/.local/share/code-server/Machine/settings.json &&\
    mkdir -p /root/.local/share/code-server/User/snippets/ &&\ 
    cp -f /common/snippets-vscode/* /root/.local/share/code-server/User/snippets/

# 配置bash并设置默认终端为bash（使用全局配置，所有用户共享）
# 这里会修改 settings.json 为bash，一定要放在后面
RUN mkdir -p /usr/local/share/bash && \
    curl -fsSL -o /usr/local/share/bash/git-prompt.bash https://cnb.cool/sumu.k/ohmybash/-/git/raw/main/git-prompt.bash && \
    curl -fsSL -o /usr/local/share/bash/git-completion.bash https://cnb.cool/sumu.k/ohmybash/-/git/raw/main/git-completion.bash && \
    chmod +x /usr/local/share/bash/git-*.bash /common/scripts/set-global-bash-env.sh && \
    bash /common/scripts/set-global-bash-env.sh && \
    chsh -s $(which bash)

# 安装 node 和 claude code
RUN git clone https://cnb.cool/sumu.k/my-linux /tmp/my-linux &&\
    cd /tmp/my-linux/Frontend &&\
    chmod +x *.sh &&\
    bash -c './nodejs.sh' &&\
    bash -c './claude.sh' &&\
    rm -rf /tmp/my-linux

# 安装 skills, 当 存在一个 ~/.codebuddy/skills/SKILL.md 的时候会导致codebuddy 无法正常读取用户 siklls
RUN mkdir -p ~/.codebuddy/skills && \
    git clone https://cnb.cool/sumu.k/my-skills /tmp/my-skills &&\
    cp -rf /tmp/my-skills/skills/* ~/.codebuddy/skills/ &&\
    rm -rf /tmp/my-skills ~/.codebuddy/skills/SKILL.md

# 创建用户 sumu,此时系统将会有2个用户 root、sumu
RUN useradd -m -s /bin/bash sumu && \
    echo "sumu:000000" | chpasswd && \
    passwd -u root && \
    echo "root:000000" | chpasswd && \
    usermod -aG sudo sumu

# 处理其他文件并清理拷贝过来的common目录
RUN cp -f /common/gitconfig /root/.gitconfig &&\
    cp -f /common/scripts/repo-init-from /usr/local/bin/repo-init-from &&\
    chmod +x /usr/local/bin/repo-init-from &&\
    rm -rf /common
