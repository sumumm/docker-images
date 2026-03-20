FROM docker.cnb.cool/sumu.k/docker-learning/ubuntu-22.04

# 更新软件包
RUN apt-get update && \
    apt-get install -y xz-utils tree && \
    apt-get install -y gcc-9 make cmake bison flex libncurses-dev bc libssl-dev lzop bear file &&\
    apt-get install -y python3 &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# 安装repo
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && \
    chmod a+x /usr/local/bin/repo &&\
    ln -s /usr/bin/python3 /usr/bin/python

# install vscode and extension
RUN code-server --install-extension mads-hartmann.bash-ide-vscode &&\
    code-server --install-extension llvm-vs-code-extensions.vscode-clangd &&\
    code-server --install-extension xaver.clang-format &&\
    code-server --install-extension ms-vscode.hexeditor 

# 安装交叉编译工具
WORKDIR ./scripts
COPY dev-env/embedded/script/arm-gcc.sh .
RUN chmod +x arm-gcc.sh && \
    bash ./arm-gcc.sh
