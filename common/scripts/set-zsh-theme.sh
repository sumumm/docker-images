#!/usr/bin/env bash

# set-zsh-theme.sh - 设置 .zshrc 的 ZSH_THEME 配置

set -euo pipefail

usage() {
    echo "用法: $0 <主题名>"
    echo "示例: $0 risto"
    echo "       $0 agnoster"
    exit 1
}

# 检查参数
if [[ $# -eq 0 ]]; then
    echo "错误: 需要指定主题名称"
    usage
fi

# 获取要设置的主题
THEME_NAME="$1"

# 主处理函数
set_theme() {
    local zshrc_file="$HOME/.zshrc"
    local backup_file="$zshrc_file.bak"
    local tmp_file="$zshrc_file.tmp"
    
    # 检查文件存在
    if [[ ! -f "$zshrc_file" ]]; then
        echo "错误: $zshrc_file 不存在"
        exit 2
    fi
    
    # 创建备份
    cp -f "$zshrc_file" "$backup_file"
    
    # 使用 AWK 处理文件
    awk -v theme="$THEME_NAME" '
    /^[[:space:]]*ZSH_THEME[[:space:]]*=/ {
        # 提取等号位置
        eq_pos = index($0, "=")
        if (eq_pos) {
            # 获取引号类型
            rest = substr($0, eq_pos + 1)
            # 匹配双引号或单引号包裹的值
            if (match(rest, /"[^"]*"/) || match(rest, /'"'"'[^'"'"']*'"'"'/)) {
                quote_char = substr(rest, RSTART, 1)
                $0 = substr($0, 1, eq_pos) quote_char theme quote_char
            } else {
                # 无引号的情况，添加双引号
                $0 = substr($0, 1, eq_pos) "\"" theme "\""
            }
        }
    }
    { print }
    ' "$zshrc_file" > "$tmp_file"
    
    # 替换原文件
    mv -f "$tmp_file" "$zshrc_file"
    
    echo "成功更新 $zshrc_file"
    echo "原始文件已备份至: $backup_file"
}

# 执行主函数
set_theme

# 显示变更
echo -e "\n变更内容:"
diff --color=always -u "$HOME/.zshrc.bak" "$HOME/.zshrc" || true
