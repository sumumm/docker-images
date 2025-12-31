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
IMAGE_NAME="exercise3"
EXPECTED_TEXT="Hello from Rust"
MAX_SIZE_MB=20

prt "1. Building Docker image..."
if ! docker build -t "${IMAGE_NAME}" .; then
    error "Docker image build failed"
    exit 1
fi

prt "2. Testing output content..."
output=$(docker run "${IMAGE_NAME}")
prt "Container output:"
echo "${output}"
if ! echo "${output}" | grep -q "${EXPECTED_TEXT}"; then
    error "Expected text '${EXPECTED_TEXT}' not found in container output"
    exit 1
fi
success "Output test passed!"

prt "3. Checking image size..."
size=$(docker inspect --format='{{.Size}}' "${IMAGE_NAME}")
size_mb=$((size / 1024 / 1024))
if [ ${size_mb} -ge ${MAX_SIZE_MB} ]; then
    error "Image size ${size_mb}MB ≥ ${MAX_SIZE_MB}MB"
    exit 1
fi
success "Image size ${size_mb}MB < ${MAX_SIZE_MB}MB"

success "${IMAGE_NAME} all tests passed!"