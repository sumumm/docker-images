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
    apt-get install -y curl wget unzip git openssh-client openssh-server vim jq sudo bash-completion lsof && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# 安装 cloudflared（Cloudflare Tunnel 客户端）
# 用途：CNB 云环境无法做 L3 VPN/端口映射，只能出方向访问公网，
#      需要 cloudflared access ssh/tcp 接入 Windows 侧的快速隧道（Quick Tunnel）
RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(. /etc/os-release && echo "${VERSION_CODENAME}") main" > /etc/apt/sources.list.d/cloudflared.list && \
    apt-get update && \
    apt-get install -y cloudflared && \
    cloudflared --version && \
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
    code-server --install-extension EditorConfig.EditorConfig &&\
    code-server --install-extension ms-vs-extensions.vssm-tool

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
    bash -c 'NODE_VERSION=24 ./nodejs.sh' &&\
    bash -c './claude.sh' &&\
    rm -rf /tmp/my-linux

# 安装 skills（软链接安装，推荐）, 当 存在一个 ~/.codebuddy/skills/SKILL.md 的时候会导致codebuddy 无法正常读取用户 siklls
# 软链接方式通过 ~/.smskills 中间镜像层解耦仓库路径，删除临时克隆目录后 agent 链接不会断
# 先 update 做本地镜像，再用 link 按需链接指定工具
RUN git clone https://cnb.cool/smk.h/my-skills /tmp/my-skills &&\
    chmod +x /tmp/my-skills/linux-skills.sh &&\
    /tmp/my-skills/linux-skills.sh update &&\
    /tmp/my-skills/linux-skills.sh link claude &&\
    /tmp/my-skills/linux-skills.sh link opencode &&\
    /tmp/my-skills/linux-skills.sh link codebuddy &&\
    /tmp/my-skills/linux-skills.sh link zcode &&\
    /tmp/my-skills/linux-skills.sh link dsh &&\
    rm -rf /tmp/my-skills

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
