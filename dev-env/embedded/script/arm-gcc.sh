
#!/bin/bash
# * =====================================================
# * Copyright © hk. 2022-2025. All rights reserved.
# * File name  : arm-gcc.sh
# * Author     : 苏木
# * Date       : 2024-11-02
# * Description: 安装 arm-gcc 工具链,目前只支持bash自动加载环境变量并生效
# * 
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

SOFTWARE_DIR_PATH=/opt             # 软件安装目录（系统级，所有用户可访问）

# 系统级环境变量配置文件，放在 /etc/profile.d/ 下会在所有用户登录时自动 source 加载
# 该文件中写入 export PATH=... 使 arm-gcc 工具链对所有用户生效
ENV_PROFILE_FILE="/etc/profile.d/arm-gcc.sh"
# 系统级 bashrc 文件，所有用户的每次交互式 bash 启动时都会加载
# 写入该文件可确保非登录 shell（如 VS Code 新开终端、直接执行 bash）也能获取到 PATH
BASH_BASHRC="/etc/bash.bashrc"

COMPRESS_PACKAGE=gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz # 定义压缩包名称
PACKAGE_NAME=${COMPRESS_PACKAGE%.tar.xz}
INSTALL_PATH=${SOFTWARE_DIR_PATH}/${PACKAGE_NAME} # 定义编译后安装--生成的文件,文件夹位置路径
# 下载地址：https://developer.arm.com/downloads/-/gnu-rm
# https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz
DOWNLOAD_LINK=https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/${COMPRESS_PACKAGE}

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
#下载源码包
function do_download_src () 
{
   echo -e "${YELLOW}➤ start download ${COMPRESS_PACKAGE}...${CLS}"
   if [ ! -f "${COMPRESS_PACKAGE}" ];then
      if [ ! -d "${PACKAGE_NAME}" ];then
        wget ${Q} -c ${DOWNLOAD_LINK}
      fi
   fi
   echo -e "${YELLOW}done...${CLS}"
}

# 解压源码包
function do_tar_package () 
{
   echo -e "${YELLOW}➤ start unpacking the ${PACKAGE_NAME} package ...${CLS}"

   mkdir -p ${INSTALL_PATH}

   if [ ! -d "${PACKAGE_NAME}" ];then
      tar -xf ${COMPRESS_PACKAGE} -C ${INSTALL_PATH} --strip-components=1
   fi
   echo -e "${YELLOW}done...${CLS}"
}

# 删除下载的文件
function do_delete_file () 
{
   cdi ${SCRIPT_ABSOLUTE_PATH}
   if [ -f "${COMPRESS_PACKAGE}" ];then
      rm -f ${COMPRESS_PACKAGE}
   fi
   cdo
}

function add_env_info()
{
    echo -e "${YELLOW}➤ start modify the environment variable...${CLS}"

    NEW_PATH="${SOFTWARE_DIR_PATH}/${PACKAGE_NAME}/bin"

    # 写入 /etc/profile.d/，登录 shell（bash -l）时自动加载
    if [ ! -f "${ENV_PROFILE_FILE}" ]; then
        echo "export PATH=${NEW_PATH}:\$PATH" > "${ENV_PROFILE_FILE}"
        chmod 644 "${ENV_PROFILE_FILE}"
    else
        if ! grep -q "${NEW_PATH}" "${ENV_PROFILE_FILE}"; then
            echo "export PATH=${NEW_PATH}:\$PATH" >> "${ENV_PROFILE_FILE}"
        fi
    fi

    # 写入 /etc/bash.bashrc，非登录 shell（VS Code 新开终端等）时自动加载
    if ! grep -q "${NEW_PATH}" "${BASH_BASHRC}" 2>/dev/null; then
        echo "export PATH=${NEW_PATH}:\$PATH" >> "${BASH_BASHRC}"
    fi

    # 更新当前 shell 的 PATH（使其立即生效）
    export PATH=${NEW_PATH}:$PATH
    echo -e "${YELLOW}done...${CLS}"
}

function show_arm_gcc_version()
{
    gnueabihf_gcc_version=$(arm-linux-gnueabihf-gcc --version | sed -n "1p")
    echo ${gnueabihf_gcc_version}
}

# 卸载：删除安装目录和环境变量配置
function do_uninstall()
{
    echo -e "${YELLOW}➤ uninstalling arm-gcc ...${CLS}"

    # 删除环境变量配置文件
    if [ -f "${ENV_PROFILE_FILE}" ]; then
        rm -f "${ENV_PROFILE_FILE}"
        echo -e "removed ${ENV_PROFILE_FILE}"
    fi

    # 清除 /etc/bash.bashrc 中写入的 PATH 配置
    if [ -f "${BASH_BASHRC}" ]; then
        sed -i "\|${SOFTWARE_DIR_PATH}/${PACKAGE_NAME}/bin|d" "${BASH_BASHRC}"
        echo -e "cleaned PATH from ${BASH_BASHRC}"
    fi

    # 删除安装目录
    if [ -d "${INSTALL_PATH}" ]; then
        rm -rf "${INSTALL_PATH}"
        echo -e "removed ${INSTALL_PATH}"
    fi

    # 从当前 shell 的 PATH 中移除
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v "${SOFTWARE_DIR_PATH}/${PACKAGE_NAME}/bin" | tr '\n' ':' | sed 's/:$//')

    echo -e "${GREEN}uninstall done.${CLS}"
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

if [ "$1" = "uninstall" ]; then
    do_uninstall
else
    do_download_src
    do_tar_package
    do_delete_file
    add_env_info
    show_arm_gcc_version
fi

exit $?
