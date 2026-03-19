
#!/bin/bash
# * =====================================================
# * Copyright © hk. 2022-2025. All rights reserved.
# * File name  : arm-gcc.sh
# * Author     : 苏木
# * Date       : 2024-11-02
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

INFO="${GREEN}[INFO]${CLS}"
WARN="${YELLOW}[WARN]${CLS}"
ERR="${RED}[ERR ]${CLS}"

SHELL_ARGC=$#
SHELL_PARAM=$@

SCRIPT_NAME=${0#*/}
SCRIPT_CURRENT_PATH=${0%/*}
SCRIPT_ABSOLUTE_PATH=`cd $(dirname ${0}); pwd`
Q=$1                                 # github actions 调用的时候不想显示一些信息，就可以传入这个参数 -q

# Github Actions托管的linux服务器有以下用户级环境变量，系统级环境变量加上sudo好像也权限修改
# .bash_logout  当用户注销时，此文件将被读取，通常用于清理工作，如删除临时文件。
# .bashrc       此文件包含特定于 Bash Shell 的配置，如别名和函数。它在每次启动非登录 Shell 时被读取。
# .profile、.bash_profile 这两个文件位于用户的主目录下，用于设置特定用户的环境变量和启动程序。当用户登录时，
#                        根据 Shell 的类型和配置，这些文件中的一个或多个将被读取。

SYSTEM_ENVIRONMENT_FILE=/etc/profile # 系统环境变量位置
USER_ENV_FILE_BASHRC=~/.bashrc
USER_ENV_FILE_PROFILE=~/.profile
SOFTWARE_DIR_PATH=~/smbin        # 软件安装目录

HOST=arm-linux-gnueabihf
SCRIPT_PATH=$(pwd)

MAJOR_NAME=gcc-arm-linux-gnueabihf # 源码包解压后的名称

OPENSRC_VER_PREFIX=8.3             # 需要下载的源码版本前缀和后缀
OPENSRC_VER_SUFFIX=.0
PACKAGE_NAME=${MAJOR_NAME}-${OPENSRC_VER_PREFIX}${OPENSRC_VER_SUFFIX}
COMPRESS_PACKAGE=gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz # 定义压缩包名称

INSTALL_PATH=${SOFTWARE_DIR_PATH}/${PACKAGE_NAME} # 定义编译后安装--生成的文件,文件夹位置路径

# 目录切换函数定义
# --------------------------------------------------------
function cdi()
{
    if command -v pushd &>/dev/null; then
        # 压栈并切换
        pushd $1 >/dev/null || return 1
    else
        cd $1
    fi
}

function cdo()
{
    if command -v popd &>/dev/null; then
        # 弹出并恢复
        popd >/dev/null || return 1
    else
        cd -
    fi
}

# ========================================================

# 无需修改--下载地址
# https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz
DOWNLOAD_LINK=https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/${COMPRESS_PACKAGE}

#下载源码包
function do_download_src () 
{
   echo -e "${YELLOW}mstart download ${COMPRESS_PACKAGE}...${CLS}"
   if [ ! -f "${COMPRESS_PACKAGE}" ];then
      if [ ! -d "${PACKAGE_NAME}" ];then
        wget ${Q} -c ${DOWNLOAD_LINK}
      fi
   fi
   echo -e "${YELLOW}mdone...${CLS}"
}

# 解压源码包
function do_tar_package () 
{
   echo -e "${YELLOW}mstart unpacking the ${PACKAGE_NAME} package ...${CLS}"

   mkdir -p ${INSTALL_PATH}

   if [ ! -d "${PACKAGE_NAME}" ];then
      tar -xf ${COMPRESS_PACKAGE} -C ${INSTALL_PATH} --strip-components=1
   fi
   echo -e "${YELLOW}mdone...${CLS}"
}

# 删除下载的文件
function do_delete_file () 
{
   cdi ${SCRIPT_PATH}
   if [ -f "${COMPRESS_PACKAGE}" ];then
      rm -f ${COMPRESS_PACKAGE}
   fi
   cdo
}

function add_env_info()
{
    NEW_PATH="${SOFTWARE_DIR_PATH}/${PACKAGE_NAME}/bin"

    # 写入 zsh 配置文件（检查是否已存在）
    if [ -f ${USER_ENV_FILE_BASHRC} ]; then
        if ! grep -q "${NEW_PATH}" ${USER_ENV_FILE_BASHRC}; then
            echo "export PATH=${NEW_PATH}:\$PATH" >> ${USER_ENV_FILE_BASHRC}
        fi
    fi

    # 修改可能出现的其他用户级环境变量，防止不生效
    if [ -f ${USER_ENV_FILE_PROFILE} ]; then
        if ! grep -q "${NEW_PATH}" ${USER_ENV_FILE_PROFILE}; then
            echo "export PATH=${NEW_PATH}:\$PATH" >> ${USER_ENV_FILE_PROFILE}
        fi
    fi

    # 更新当前 shell 的 PATH（使其立即生效）
    export PATH=${NEW_PATH}:$PATH
}

function show_arm_gcc_version()
{
    gnueabihf_gcc_version=$(arm-linux-gnueabihf-gcc --version | sed -n "1p")
    echo ${gnueabihf_gcc_version}
}

# * ======================================================
# 打印菜单
function do_echo_menu()
{
	echo "================================================="
	echo -e "${GREEN}               arm-gcc ${CLS}"
	echo "================================================="
	echo -e "${PINK}current path        :$(pwd)${CLS}"
    echo -e "${PINK}SCRIPT_CURRENT_PATH :${SCRIPT_CURRENT_PATH}${CLS}"
    echo -e "${PINK}SCRIPT_ABSOLUTE_PATH:${SCRIPT_ABSOLUTE_PATH}${CLS}"
    echo -e "${PINK}SHELL_PARAM         :(${SHELL_ARGC} total)arg=${SHELL_PARAM}${CLS}"
	echo ""
	echo "================================================="
}

do_echo_menu

do_download_src
do_tar_package
do_delete_file
add_env_info
show_arm_gcc_version

exit $?
