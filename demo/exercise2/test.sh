#!/bin/bash
set -euo pipefail

# 颜色和日志标识
# ========================================================
# |      ---       |Black |  Red | Green | Yellow | Blue | Magenta | Cyan | White |
# | Fore(Standard) |  30  |  31  |  32   |   33   |  34  |   35    |  35  |   37  |
# | Fore(light)    |  90  |  91  |  92   |   93   |  94  |   95    |  95  |   97  |
# | Back(Standard) |  40  |  41  |  42   |   43   |  44  |   45    |  46  |   47  |
# | Back(light)    | 100  | 101  | 102   |  103   | 104  |  105    | 106  |  107  |
BLACK="\033[1;30m"
RED='\033[1;31m'    # 红
GREEN='\033[1;32m'  # 绿
YELLOW='\033[1;33m' # 黄
BLUE='\033[1;34m'   # 蓝
PINK='\033[1;35m'   # 紫
CYAN='\033[1;36m'   # 青
WHITE='\033[1;37m'  # 白
CLS='\033[0m'       # 清除颜色

INFO="${GREEN}INFO: ${CLS}"
WARN="${YELLOW}WARN: ${CLS}"
ERROR="${RED}ERROR: ${CLS}"

function sh_log()
{
    LOG_COLOR="$1"           # 获取要显示的前景色
    shift                    # 参数左移
    if [ "$1" = "-n" ]; then # -n表示取消echo的换行
        shift
        LOG_FLAG="-ne"
    else
        LOG_FLAG="-e"
    fi
    echo $LOG_FLAG "\e[${LOG_COLOR}m$@\e[0m"
}

function prt()
{
    sh_log 0 "$@" # default
}

function warning()
{
    echo -n "⚠️  "
    sh_log 33 "$@" # dark yellow
}

function error()
{
    echo -n "🔖 "
    sh_log 91 "$@" # light red
}

function success()
{
    echo -n "✅ "
    sh_log 32 "$@" # green
}

function log_echo_demo()
{
    prt -n "Log colors:|"
    success -n " success |"
    warning -n " warning |"
    error -n " error |"
    echo
}

# ========================================================
IMAGE_NAME="exercise2"
CONTAINER_NAME="${IMAGE_NAME}_test"
PORT=5000
EXPECTED_TEXT="Hello Docker!"

# 清理函数
cleanup() {
    prt "Cleaning up..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
}

# 设置 trap，确保脚本退出时执行清理
trap cleanup EXIT

prt "1. Building Docker image..."
docker build -t "${IMAGE_NAME}" .

prt "2. Starting container..."
docker run -d -p "${PORT}:5000" --name "${CONTAINER_NAME}" "${IMAGE_NAME}"

prt "3. Waiting for container to be ready..."
# 使用 curl 重试机制，最多等待 30 秒
if ! curl --retry 10 --retry-delay 2 --retry-all-errors --fail -s "http://127.0.0.1:${PORT}" > /dev/null; then
    error "Container failed to become ready!"
    docker logs "${CONTAINER_NAME}"
    exit 1
fi

prt "4. Testing content..."
if ! curl -s "http://127.0.0.1:${PORT}" | grep -q "${EXPECTED_TEXT}"; then
    error "Expected text '${EXPECTED_TEXT}' not found"
    content=$(curl -s "http://127.0.0.1:${PORT}")
    error "Actual content: ${content}"
    exit 1
fi

success "${IMAGE_NAME} test passed!"