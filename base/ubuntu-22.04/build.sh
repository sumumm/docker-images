#!/bin/bash

IMAGE_NAME="${CNB_DOCKER_REGISTRY}/${CNB_REPO_SLUG_LOWERCASE}/ubuntu-22.04"
NO_CACHE=""

show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -b       构建镜像"
    echo "  -p       推送镜像"
    echo "  -r       运行镜像"
    echo "  -c c|i   清除所有容器(c)或镜像(img)"
    echo "  -a       执行所有操作 (构建+推送+运行)"
    echo "  -f       构建时不使用缓存 (--no-cache)"
    echo "  -h       显示帮助信息"
}

build_image() {
    echo "=========================================="
    echo "构建镜像: $IMAGE_NAME"
    echo "=========================================="
    # docker build --no-cache -t "$IMAGE_NAME" .
    docker build $NO_CACHE -f "$(dirname "$0")/Dockerfile" -t "$IMAGE_NAME" "$(dirname "$0")/../.."
}

# 查询 CNB 远程制品信息：制品存在性、标签列表、出生证明
# 参数: $1=slug, $2=pkg_type, $3=pkg_name, $4=arch(可选, 默认linux/amd64)
# 返回: 0=制品存在, 1=制品不存在
query_package() {
    local slug="$1"
    local pkg_type="$2"
    local pkg_name="$3"
    local arch="${4:-linux/amd64}"
    local api_url="${CNB_API_ENDPOINT}/${slug}/-/packages/${pkg_type}/${pkg_name}"

    # 1. 查询制品是否存在
    echo "正在查询远程制品: $api_url"
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X GET "$api_url" \
        -H "Accept: application/vnd.cnb.api+json" \
        -H "Authorization: Bearer $CNB_TOKEN")

    echo "API 返回状态码: $http_code"

    if [ "$http_code" != "200" ]; then
        echo "未找到已有制品"
        return 1
    fi

    # 2. 查询并打印标签列表
    echo "发现已存在的远程制品:"
    echo "  ${slug}/-/packages/${pkg_type}/${pkg_name}"
    echo ""
    local tag_list
    tag_list=$(curl -s -X GET "${api_url}/-/tags" \
        -H "Accept: application/vnd.cnb.api+json" \
        -H "Authorization: Bearer $CNB_TOKEN")
    echo "--- 制品标签列表 ---"
    echo "$tag_list" | jq '.' 2>/dev/null || echo "$tag_list"

    # 3. 遍历每个 tag，获取出生证明 (GetPackageTagProvenance)
    echo ""
    echo "--- 制品出生证明 ---"
    local tags
    tags=$(echo "$tag_list" | jq -r '.docker[].name // empty' 2>/dev/null)
    for tag in $tags; do
        [ -z "$tag" ] && continue
        echo ">>> Tag: ${tag}"
        curl -s -X GET "${api_url}/-/tag/${tag}/provenance" \
            -H "Accept: application/vnd.cnb.api+json" \
            -H "Authorization: Bearer $CNB_TOKEN" \
            -G --data-urlencode "arch=${arch}" | jq '.' 2>/dev/null || echo "  (无出生证明或查询失败)"
        echo ""
    done
    echo "--- 出生证明结束 ---"
    return 0
}

push_image() {
    echo "=========================================="
    echo "推送镜像: $IMAGE_NAME"
    echo "=========================================="

    # local slug="${CNB_REPO_SLUG}"
    # query_package "$slug" "docker" "ubuntu-22.04" "linux/amd64"

    docker push "$IMAGE_NAME"
}

run_image() {
    echo "=========================================="
    echo "运行镜像: $IMAGE_NAME"
    echo "=========================================="
    # 容器启动后直接进入了sumu用户，运行sudo命令会报错，这里需要加上--security-opt选项
    # true	禁止进程获取新权限（sudo、setuid 程序失效）
    # false	允许进程获取新权限（sudo 正常工作）
    # docker run -it --rm --security-opt=no-new-privileges:false "$IMAGE_NAME" bash
    docker run -it --rm -p 8000:8000 --entrypoint "code-server" -d "$IMAGE_NAME" --bind-addr=0.0.0.0:8000 --auth=none
}

clean() {
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

    while getopts "bfprc:ah" opt; do
        case $opt in
            b)
                build_image
                ;;
            f)
                NO_CACHE="--no-cache"
                ;;
            p)
                push_image
                ;;
            r)
                run_image
                ;;
            c)
                clean "$OPTARG"
                ;;
            a)
                build_image && push_image && run_image
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
