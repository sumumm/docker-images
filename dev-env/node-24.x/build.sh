#!/bin/bash

REPO_NAME="${CNB_REPO_SLUG_LOWERCASE#*/}"
PKG_NAME="node-24.x"
IMAGE_NAME="${CNB_DOCKER_REGISTRY}/${CNB_REPO_SLUG_LOWERCASE}/${PKG_NAME}"
NO_CACHE=""

# API 配置
API_URL="${CNB_API_ENDPOINT:-https://api.cnb.build}"
TOKEN="${REGISTRY_PKG_ACCESS_TOKEN:-$CNB_TOKEN}"

declare -a HEADERS=(
  -H "Accept: application/vnd.cnb.api+json"
  -H "Authorization: Bearer ${TOKEN}"
)

# 发送 GET 请求，输出响应体
api_get() {
  local url="$1"
  curl -s -f \
       --request GET \
       --url "$url" \
       "${HEADERS[@]}" \
       || echo ''
}

# 发送 DELETE 请求
api_delete() {
  local url="$1"
  local status
  status=$(curl -s -o /dev/null -w '%{http_code}' \
                --request DELETE \
                --url "$url" \
                "${HEADERS[@]}")
  echo "删除请求状态码: ${status}"
  if [[ "$status" == 2?? ]]; then
    return 0
  else
    return 1
  fi
}

# 打印制品标签列表
# 用法: print_package_tags <api_url>
print_package_tags() {
    local api_url="$1"
    local tags_json
    tags_json=$(api_get "${api_url}/-/tags")
    if [[ -n "$tags_json" ]]; then
        echo "制品标签列表:"
        echo "$tags_json" | jq -r '.docker[]?.name // empty' 2>/dev/null | while IFS= read -r tag; do
            echo "  - ${tag}"
        done
    fi
}

show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -b           构建镜像"
    echo "  -p           推送镜像"
    echo "  -r run       运行镜像"
    echo "  -r get       查询远程镜像"
    echo "  -r delete    删除远程镜像"
    echo "  -c c|i       清除所有容器(c)或镜像(img)"
    echo "  -a           执行所有操作 (构建+推送+运行)"
    echo "  -f           构建时不使用缓存 (--no-cache)"
    echo "  -h           显示帮助信息"
}

do_build_image() {
    echo "=========================================="
    echo "构建镜像: $IMAGE_NAME"
    echo "=========================================="
    # docker build --no-cache -t "$IMAGE_NAME" .
    docker build $NO_CACHE -f "$(dirname "$0")/Dockerfile" -t "$IMAGE_NAME" "$(dirname "$0")/../.."
}

do_push_image() {
    echo "=========================================="
    echo "推送镜像: $IMAGE_NAME"
    echo "=========================================="

    docker push "$IMAGE_NAME"
}

do_run_image() {
    echo "=========================================="
    echo "运行镜像: $IMAGE_NAME"
    echo "=========================================="
    # 容器启动后直接进入了sumu用户，运行sudo命令会报错，这里需要加上--security-opt选项
    # true	禁止进程获取新权限（sudo、setuid 程序失效）
    # false	允许进程获取新权限（sudo 正常工作）
    # docker run -it --rm --security-opt=no-new-privileges:false "$IMAGE_NAME" bash
    docker run -it --rm --security-opt=no-new-privileges:false -p 8000:8000 --entrypoint "code-server" -d "$IMAGE_NAME" --bind-addr=0.0.0.0:8000 --auth=none
}

do_get_remote_image() {
    local api_url="${API_URL}/${CNB_REPO_SLUG}/-/packages/docker/${REPO_NAME}/${PKG_NAME}"
    echo "=========================================="
    echo "查询远程镜像: ${REPO_NAME}/${PKG_NAME}"
    echo "=========================================="
    local response
    response=$(api_get "$api_url")
    if [[ -n "$response" ]]; then
        echo "远程镜像信息:"
        echo "$response" | jq .
        print_package_tags "$api_url"
    else
        echo "未找到远程镜像"
    fi
}

# 删除远程镜像（整个制品，包括所有标签）
# 注意：DeletePackage API 会删除该制品的全部标签，不是仅删除单个标签
do_delete_remote_image() {
    local api_url="${API_URL}/${CNB_REPO_SLUG}/-/packages/docker/${REPO_NAME}/${PKG_NAME}"
    echo "=========================================="
    echo "删除远程镜像: ${REPO_NAME}/${PKG_NAME}"
    echo "=========================================="
    local response
    response=$(api_get "$api_url")
    if [[ -n "$response" ]]; then
        echo "发现远程镜像: $api_url"
        print_package_tags "$api_url"
        echo "准备删除..."
        if api_delete "$api_url"; then
            echo "远程镜像已删除"
        else
            echo "删除远程镜像失败"
        fi
    else
        echo "未找到远程镜像"
    fi
}

do_clean() {
    local clean_type="$1"
    case "$clean_type" in
        c|containers)
            echo "=========================================="
            echo "清除所有容器"
            echo "=========================================="
            docker ps -aq | xargs -r docker stop
            docker ps -aq | xargs -r docker rm
            echo "所有容器已清除"
            ;;
        i|images)
            echo "=========================================="
            echo "清除所有镜像"
            echo "=========================================="
            docker images -aq | xargs -r docker rmi -f
            echo "所有镜像已清除"
            ;;
        *)
            echo "无效参数: $clean_type"
            echo "用法: -c c (清除容器) 或 -c img (清除镜像)"
            exit 1
            ;;
    esac
}

main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi

    while getopts "bfpr:c:ah" opt; do
        case $opt in
            b)
                do_build_image
                ;;
            f)
                NO_CACHE="--no-cache"
                ;;
            p)
                do_push_image
                ;;
            r)
                case "$OPTARG" in
                    run|r)
                        do_run_image
                        ;;
                    get|g)
                        do_get_remote_image
                        ;;
                    delete|d)
                        do_delete_remote_image
                        ;;
                    *)
                        echo "无效的 -r 参数: $OPTARG" >&2
                        show_help
                        exit 1
                        ;;
                esac
                ;;
            c)
                do_clean "$OPTARG"
                ;;
            a)
                do_build_image && do_push_image && do_run_image
                ;;
            h)
                show_help
                ;;
            \?)
                echo "无效选项: -$OPTARG" >&2
                show_help
                exit 1
                ;;
        esac
    done
}

main "$@"
