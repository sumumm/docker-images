FROM debian:bookworm

# 更新软件包
# build-essential 提供 make/gcc/g++，用于 npm 原生模块（node-gyp）的源码编译，
# 例如 @dimava/serialport-bindings-cpp 只有 win32 预编译产物，Linux 上必须现编
RUN apt-get update && \
    apt-get install -y curl wget unzip git openssh-client openssh-server vim zsh build-essential && \
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

# install vscode and extension
RUN curl -fsSL https://code-server.dev/install.sh | sh &&\
    code-server --install-extension cnbcool.cnb-welcome &&\
    code-server --install-extension redhat.vscode-yaml &&\
    code-server --install-extension cloudstudio.live-server &&\
    code-server --install-extension tencent-cloud.coding-copilot &&\
    code-server --install-extension PKief.material-icon-theme &&\
    code-server --install-extension github.github-vscode-theme &&\
    code-server --install-extension EditorConfig.EditorConfig &&\
    code-server --install-extension ms-vs-extensions.vssm-tool

# zsh终端安装与配置(code-server 默认使用 zsh 终端)
COPY common/scripts ./scripts
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    chmod +x ./scripts/*.sh && \
    ./scripts/add-zsh-plugins.sh zsh-autosuggestions zsh-syntax-highlighting && \
    ./scripts/set-zsh-env.sh && \
    echo 'setopt NO_AUTO_REMOVE_SLASH' >> /root/.zshrc && \
    mkdir -p ~/.oh-my-zsh/completions && \
    chsh -s $(which zsh)

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

# 安装 node 和 claude code
RUN git clone https://cnb.cool/sumu.k/my-linux /tmp/my-linux &&\
    cd /tmp/my-linux/Frontend &&\
    chmod +x *.sh &&\
    bash -c 'NODE_VERSION=24 ./nodejs.sh' &&\
    bash -c './claude.sh' &&\
    bash -c './opencode.sh' &&\
    rm -rf /tmp/my-linux

# 安装 CNB 官方技能（cnb-skill 仓库 14 个 cnb-* 技能）
# 前置依赖：cnb-cli 提供 `cnb` 命令（技能内部会调用它），skills CLI 提供 `npx skills`
# 必须放在 node 安装之后：npm/npx 均来自上面的 nodejs.sh
# nodejs.sh 已把 npm 全局前缀设为 ~/.npm-global，但它只写入 ~/.bashrc/~/.zshrc，
# 非交互的 RUN 环境取不到，故这里显式补进 PATH
ENV PATH="/root/.npm-global/bin:${PATH}"
# 默认「全局规范目录 + 软链接」模式，实测落盘：
#   ~/.agents/skills/<skill>      真实文件（OpenCode 等 universal agent 直接读取）
#   ~/.claude/skills/<skill>      软链接 -> ../../.agents/skills/<skill>
#   ~/.codebuddy/skills/<skill>   软链接 -> ../../.agents/skills/<skill>
# 显式指定 --agent 而非依赖自动探测，避免构建期 agent 目录尚未生成导致漏链
RUN npm install -g @cnbcool/cnb-cli skills@1.5.23 && \
    npx skills add https://cnb.cool/cnb/skills/cnb-skill.git -g -y --agent codebuddy --agent claude-code --agent opencode && \
    cnb --version && \
    ls /root/.agents/skills

# 安装 skills（软链接安装，推荐）, 当 存在一个 ~/.codebuddy/skills/SKILL.md 的时候会导致codebuddy 无法正常读取用户 siklls
# 软链接方式通过 ~/.smskills 中间镜像层解耦仓库路径，删除临时克隆目录后 agent 链接不会断
# 先 update 做本地镜像，再用 link 按需链接指定工具
RUN git clone https://cnb.cool/smk.h/my-skills /tmp/my-skills &&\
    chmod +x /tmp/my-skills/linux-skills.sh &&\
    /tmp/my-skills/linux-skills.sh update &&\
    /tmp/my-skills/linux-skills.sh link claude &&\
    /tmp/my-skills/linux-skills.sh link opencode &&\
    /tmp/my-skills/linux-skills.sh link codebuddy &&\
    rm -rf /tmp/my-skills

# 指定字符集支持命令行输入中文（根据需要选择字符集）
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
