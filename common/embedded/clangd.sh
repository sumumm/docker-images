#!/bin/bash
# * =====================================================
# * Copyright © hk. 2022-2025. All rights reserved.
# * File name  : clangd.sh
# * Author     : 苏木
# * Date       : 2026-03-20
# * Description: 通过 apt.llvm.org 源安装 clangd 和 clang-format
# * ======================================================

##
BLACK="\033[1;30m"
RED='\033[1;31m'    # 红
GREEN='\033[1;32m'  # 绿
YELLOW='\033[1;33m' # 黄
BLUE='\033[1;34m'   # 蓝
PINK='\033[1;35m'   # 紫
CYAN='\033[1;36m'   # 青
WHITE='\033[1;37m'  # 白
CLS='\033[0m'       # 清除颜色

SHELL_ARGC=$#
SHELL_PARAM=$@

Q=$1                               # github actions 调用的时候不想显示一些信息，就可以传入这个参数 -q
SCRIPT_NAME=${0#*/}
SCRIPT_CURRENT_PATH=${0%/*}
SCRIPT_ABSOLUTE_PATH=`cd $(dirname ${0}); pwd`

# LLVM 版本号，可通过环境变量 LLVM_VERSION 覆盖
# 当前 stable: 20, qualification: 21, development(snapshot): 22
# 参考: https://apt.llvm.org/
LLVM_VERSION=${LLVM_VERSION:-20}

LLVM_GPG_KEY_URL="https://apt.llvm.org/llvm-snapshot.gpg.key"
LLVM_GPG_KEY_FILE="/etc/apt/trusted.gpg.d/apt.llvm.org.asc"
LLVM_SOURCES_LIST_DIR="/etc/apt/sources.list.d"

# ========================================================
# 检测发行版代号
function detect_codename()
{
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$VERSION_CODENAME"
    elif [ -f /etc/debian_version ]; then
        cat /etc/debian_version
    elif command -v lsb_release &>/dev/null; then
        lsb_release -cs
    else
        echo "unknown"
    fi
}

# ========================================================
# 安装 LLVM GPG 密钥
function add_llvm_gpg_key()
{
    echo -e "${YELLOW}➤ adding LLVM apt GPG key...${CLS}"

    # 已存在则跳过
    if [ -f "${LLVM_GPG_KEY_FILE}" ]; then
        echo -e "${GREEN}  GPG key already exists, skipping.${CLS}"
        return 0
    fi

    wget -qO- "${LLVM_GPG_KEY_URL}" | tee "${LLVM_GPG_KEY_FILE}" > /dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  GPG key added to ${LLVM_GPG_KEY_FILE}${CLS}"
    else
        echo -e "${RED}  failed to add GPG key!${CLS}"
        return 1
    fi
}

# ========================================================
# 添加 LLVM apt 源
function add_llvm_apt_source()
{
    echo -e "${YELLOW}➤ adding LLVM apt repository...${CLS}"

    local codename=$(detect_codename)
    if [ "${codename}" = "unknown" ]; then
        echo -e "${RED}  unable to detect distribution codename!${CLS}"
        echo -e "${RED}  please set LLVM_VERSION and codename manually.${CLS}"
        return 1
    fi

    # 生成源列表文件，存放路径: /etc/apt/sources.list.d/llvm-toolchain-<codename>-<version>.list
    # apt-get update 会自动扫描 /etc/apt/sources.list.d/ 下的所有 .list 文件作为软件源
    local source_file="${LLVM_SOURCES_LIST_DIR}/llvm-toolchain-${codename}-${LLVM_VERSION}.list"

    # 已存在则跳过
    if [ -f "${source_file}" ]; then
        echo -e "${GREEN}  apt source already exists: ${source_file}, skipping.${CLS}"
        return 0
    fi

    # .list 文件格式: deb <url> <distribution> <component>
    #   deb     : 表示二进制软件包源（apt-get install 安装的是编译好的二进制包）
    #   deb-src : 表示源码包源（apt-get source 下载的是源代码，用于编译）
    #   url     : apt 仓库地址，apt.llvm.org 根据 Debian/Ubuntu 发行版代号提供对应的包
    #   distribution : 仓库名称，格式为 llvm-toolchain-<codename>-<version>
    #   component   : 仓库组件，LLVM 使用 "main" 组件
    # 生成后的文件内容示例（Ubuntu Noble + LLVM 20）:
    #   deb http://apt.llvm.org/noble/ llvm-toolchain-noble-20 main
    #   deb-src http://apt.llvm.org/noble/ llvm-toolchain-noble-20 main
    echo "deb http://apt.llvm.org/${codename}/ llvm-toolchain-${codename}-${LLVM_VERSION} main" \
        | tee "${source_file}" > /dev/null
    echo "deb-src http://apt.llvm.org/${codename}/ llvm-toolchain-${codename}-${LLVM_VERSION} main" \
        | tee -a "${source_file}" > /dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  apt source added: ${source_file}${CLS}"
    else
        echo -e "${RED}  failed to add apt source!${CLS}"
        return 1
    fi
}

# ========================================================
# 安装 clangd 和 clang-format
function do_install()
{
    echo -e "${YELLOW}➤ installing clangd-${LLVM_VERSION} and clang-format-${LLVM_VERSION}...${CLS}"

    apt-get update ${Q}

    apt-get install -y ${Q} \
        clangd-${LLVM_VERSION} \
        clang-format-${LLVM_VERSION}

    if [ $? -ne 0 ]; then
        echo -e "${RED}  installation failed!${CLS}"
        return 1
    fi

    # 创建软链接，让 clangd 和 clang-format 命令直接可用
    echo -e "${YELLOW}➤ creating symlinks for clangd and clang-format...${CLS}"

    for tool in clangd clang-format; do
        local target="/usr/bin/${tool}-${LLVM_VERSION}"
        local link="/usr/bin/${tool}"
        if [ -f "${target}" ]; then
            ln -sf "${target}" "${link}"
            echo -e "${GREEN}  ${link} -> ${target}${CLS}"
        else
            echo -e "${RED}  ${target} not found, skipping symlink for ${tool}${CLS}"
        fi
    done
}

# ========================================================
# 卸载 clangd 和 clang-format
function do_uninstall()
{
    echo -e "${YELLOW}➤ uninstalling clangd-${LLVM_VERSION} and clang-format-${LLVM_VERSION}...${CLS}"

    # 移除软链接
    rm -f /usr/bin/clangd /usr/bin/clang-format

    # 卸载包
    apt-get remove -y ${Q} \
        clangd-${LLVM_VERSION} \
        clang-format-${LLVM_VERSION}

    apt-get autoremove -y ${Q}

    # 移除 apt 源
    local codename=$(detect_codename)
    local source_file="${LLVM_SOURCES_LIST_DIR}/llvm-toolchain-${codename}-${LLVM_VERSION}.list"
    if [ -f "${source_file}" ]; then
        rm -f "${source_file}"
        echo -e "  removed ${source_file}"
    fi

    echo -e "${GREEN}uninstall done.${CLS}"
}

# ========================================================
# 显示版本信息
function show_version()
{
    echo -e "${GREEN}clangd:${CLS}"
    clangd --version 2>/dev/null || echo -e "${RED}  clangd not found${CLS}"
    echo ""
    echo -e "${GREEN}clang-format:${CLS}"
    clang-format --version 2>/dev/null || echo -e "${RED}  clang-format not found${CLS}"
}

# ========================================================
# 打印菜单
function do_echo_menu()
{
    echo "================================================="
    echo -e "${GREEN}            clangd & clang-format installer${CLS}"
    echo "================================================="
    echo -e "${PINK}LLVM version        :${LLVM_VERSION}${CLS}"
    echo -e "${PINK}SCRIPT_ABSOLUTE_PATH:${SCRIPT_ABSOLUTE_PATH}${CLS}"
    echo -e "${PINK}SHELL_PARAM         :(${SHELL_ARGC} total)arg=${SHELL_PARAM}${CLS}"
    echo ""
    echo "================================================="
}

do_echo_menu

if [ "$1" = "uninstall" ]; then
    do_uninstall
else
    add_llvm_gpg_key || exit 1
    add_llvm_apt_source || exit 1
    do_install || exit 1
    show_version
fi

exit $?
