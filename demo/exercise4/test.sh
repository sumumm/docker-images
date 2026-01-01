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
function check_db_exists() {
    docker exec $(docker compose ps -q mysql) \
    mysql -uroot -p123456 -e "SHOW DATABASES LIKE 'testdb';" | grep testdb
}

prt "1. 启动 Docker Compose 服务..."
docker compose up -d
sleep 10 # 等待服务启动


prt "2. Checking if testdb exists (first run)..."
if check_db_exists; then
    success "testdb exists."
else
    error "testdb not exists"
    exit 1
fi

prt "3. Creating test table..."
docker exec mysql-server mysql -uroot -p123456 testdb -e "CREATE TABLE IF NOT EXISTS test_table (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"
success "Table created"

prt "4. Inserting test data..."
docker exec mysql-server mysql -uroot -p123456 testdb -e "INSERT INTO test_table (name) VALUES ('测试数据1'), ('测试数据2');"
success "Data inserted"

prt "5. Verifying data..."
output=$(docker exec mysql-server mysql -uroot -p123456 testdb -e "SELECT * FROM test_table;" 2>/dev/null)
echo "${output}"
if ! echo "${output}" | grep -q "测试数据"; then
    error "Failed to verify test data"
    exit 1
fi
success "Data verified"


prt "6. Restarting MySQL container..."
docker compose restart mysql
sleep 10 # 等待服务重启

prt "7. Checking if testdb exists (after restart)..."
if check_db_exists; then
    success "testdb still exists after restart."
else
    error "testdb not exists"
    exit 1
fi

prt "8. Verifying data persistence..."
output=$(docker exec mysql-server mysql -uroot -p123456 testdb -e "SELECT * FROM test_table;" 2>/dev/null)
echo "${output}"
if ! echo "${output}" | grep -q "测试数据"; then
    error "Data persistence failed - test data not found after restart"
    exit 1
fi
success "Data persistence verified"

docker compose down
success "====== exercise4 test passed ======="