#!/usr/bin/env bash
set -euo pipefail

API_URL="${CNB_API_ENDPOINT:-https://api.cnb.build}"
SLUG="${1:-${CNB_REPO_SLUG:-}}"
TOKEN="${REGISTRY_PKG_ACCESS_TOKEN:-$CNB_TOKEN}"
TYPE="${2:-docker}"

# 删除列表：制品名称匹配时自动删除
# 支持环境变量 DELETE_LIST（逗号分隔）或修改下方数组
IFS=',' read -ra DELETE_LIST <<< "${DELETE_LIST:-}"

# 通用请求头
declare -a HEADERS=(
  -H "Accept: application/vnd.cnb.api+json"
  -H "Authorization: Bearer ${TOKEN}"
)

# 发送 GET 请求，输出响应体
# 获取指定制品的详细信息：https://api.cnb.build/#/operations/GetPackage
# https://cnb.cool/sumu.k/docker-learning/-/packages/docker/docker-learning/python-3.11
api_get() {
  local url="$1"
  curl -s -f \
       --request GET \
       --url "$url" \
       "${HEADERS[@]}" \
       || echo ''
}

# 发送 DELETE 请求
# 删除制品：https://api.cnb.build/#/operations/DeletePackage
api_delete() {
  local url="$1"
  local status
  status=$(curl -s -o /dev/null -w '%{http_code}' \
                --request DELETE \
                --url "$url" \
                "${HEADERS[@]}")
  if [[ "$status" == 2?? ]]; then
    return 0
  else
    return 1
  fi
}

# 获取制品列表
# 用法: get_packages <slug> <type>
get_packages() {
  local slug="$1"
  local ptype="$2"
  api_get "${API_URL}/${slug}/-/packages?type=${ptype}"
}

# 获取指定制品的详细信息
# 用法: get_expect_packages <slug> <name>
#      get_expect_packages "${SLUG}" "docker" "docker-learning/python-3.11"
get_expect_packages() {
  local slug="$1"
  local ptype="$2"
  local name="$2"
# curl --request GET \
#      --url https://api.cnb.cool/sumu.k/docker-learning/-/packages/docker/docker-learning/python-3.11 \
#      --header 'Accept: application/vnd.cnb.api+json' \
#      --header 'Authorization: xxxxxxxxxxxxxxxxxxxxxxxxxxx'
  api_get "${API_URL}/${slug}/-/packages/${ptype}/${name}"
}

# 获取制品标签列表
# 用法: get_tags <slug> <type> <name>
get_tags() {
  local slug="$1"
  local ptype="$2"
  local name="$3"
  api_get "${API_URL}/${slug}/-/packages/${ptype}/${name}/-/tags?page_size=100"
}

# 删除制品
# 用法: delete_package <slug> <type> <name>
#      delete_package "${SLUG}" "docker" "docker-learning/python-3.11"
delete_package() {
  local slug="$1"
  local ptype="$2"
  local name="$3"
  if api_delete "${API_URL}/${slug}/-/packages/${ptype}/${name}"; then
    return 0
  else
    return 1
  fi
}

# 检查制品是否在删除列表中
# 用法: should_delete <name>
should_delete() {
  local name="$1"
  local item
  for item in "${DELETE_LIST[@]}"; do
    if [[ "$name" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

# 从制品列表 JSON 中提取制品名称列表
# 用法: extract_package_names <json>
extract_package_names() {
  local json="$1"
  echo "$json" | jq -r '.[] | (.package // .name) | select(. != null and . != "")'
}

# 从标签响应 JSON 中提取标签名称列表
# 用法: extract_tag_names <json> <type>
extract_tag_names() {
  local json="$1"
  local ptype="$2"
  echo "$json" | jq --arg t "$ptype" -r '
    if has($t) then .[$t][]?.name
    else to_entries[] | select(.value | type == "array") | .value[]?.name
    end | select(. != null and . != "")
  '
}

# 打印单个制品及其标签（列表格式），命中删除列表时自动删除
# 用法: print_package_tags <slug> <type> <name>
print_package_tags() {
  local slug="$1"
  local ptype="$2"
  local name="$3"

  if should_delete "$name"; then
    echo "- ${name}: [删除中...]"
    if delete_package "$slug" "$ptype" "$name"; then
      echo "  ✓ 已删除"
    else
      echo "  ✗ 删除失败"
    fi
    return
  fi

  local tags_json
  tags_json=$(get_tags "$slug" "$ptype" "$name")

  local tag_names
  tag_names=$(extract_tag_names "$tags_json" "$ptype")

  if [[ -n "$tag_names" ]]; then
    local tags_csv
    tags_csv=$(echo "$tag_names" | paste -sd ',' -)
    echo "- ${name}: ${tags_csv}"
  else
    echo "- ${name}: (无标签)"
  fi
}

# 主函数
main() {
  if [[ -z "$SLUG" ]]; then
    usage
  fi

  echo "仓库: ${SLUG}"
  echo "类型: ${TYPE}"
  echo ""

  local packages_json
  packages_json=$(get_packages "$SLUG" "$TYPE")

  local count
  count=$(echo "$packages_json" | jq 'length')

  if [[ "$count" -eq 0 ]]; then
    echo "未找到制品"
    exit 0
  fi

  echo "找到 ${count} 个制品："

  local name
  extract_package_names "$packages_json" | while IFS= read -r name; do
    print_package_tags "$SLUG" "$TYPE" "$name"
  done
}

main "$@"
