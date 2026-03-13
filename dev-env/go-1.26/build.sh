#!/bin/bash

IMAGE_NAME="${CNB_DOCKER_REGISTRY}/${CNB_REPO_SLUG_LOWERCASE}/go-1.26"

show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -b    构建镜像"
    echo "  -p    推送镜像"
    echo "  -r    运行镜像"
    echo "  -c    清除所有容器"
    echo "  -a    执行所有操作 (构建+推送+运行)"
    echo "  -h    显示帮助信息"
}

build_image() {
    echo "=========================================="
    echo "构建镜像: $IMAGE_NAME"
    echo "=========================================="
    # docker build --no-cache -t "$IMAGE_NAME" .
    docker build -f "$(dirname "$0")/Dockerfile" -t "$IMAGE_NAME" "$(dirname "$0")/../.."
}

push_image() {
    echo "=========================================="
    echo "推送镜像: $IMAGE_NAME"
    echo "=========================================="
    docker push "$IMAGE_NAME"
}

run_image() {
    echo "=========================================="
    echo "运行镜像: $IMAGE_NAME"
    echo "=========================================="
    # 容器启动后直接进入了sumu用户，运行sudo命令会报错，这里需要加上--security-opt选项
    # docker run -it --rm "$IMAGE_NAME" bash
    docker run -it --rm -p 8000:8000 --entrypoint "code-server" -d "$IMAGE_NAME" --bind-addr=0.0.0.0:8000 --auth=none
}

clean_containers() {
    echo "=========================================="
    echo "清除所有容器"
    echo "=========================================="
    docker ps -aq | xargs -r docker stop
    docker ps -aq | xargs -r docker rm
    echo "所有容器已清除"
}

main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi

    while getopts "bprcah" opt; do
        case $opt in
            b)
                build_image
                ;;
            p)
                push_image
                ;;
            r)
                run_image
                ;;
            c)
                clean_containers
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
