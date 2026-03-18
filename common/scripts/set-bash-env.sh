#!/usr/bin/env bash

# 目标文件
TARGET_FILE="$HOME/.bashrc"

# 要追加的多行内容（使用 heredoc + 单引号 EOF 避免当前 Shell 解析）
APPEND_CONTENT=$(cat <<'EOF'

# 安全地设置 VS_CODE_PATH,兼容未安装 VS Code Server 的情况
code_path=$(find /root/.vscode-server/cli/servers -name "code" -path "*/remote-cli/*" 2>/dev/null | head -1)

if [ -n "$code_path" ] && [ -f "$code_path" ]; then
    export VS_CODE_PATH="$(dirname "$code_path")"
fi

# 如果找到了，就把它的上级目录加入到 PATH 中
if [ -n "$VS_CODE_PATH" ]; then
    export PATH="$VS_CODE_PATH:$PATH"
fi

# Git 补全和提示（检查文件存在才加载）
if [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

if [ -f ~/.git-prompt.bash ]; then
    source ~/.git-prompt.bash
    set_git_ps1
fi

EOF
)


# 检查目标文件是否存在
if [ ! -f "$TARGET_FILE" ]; then
    echo "目标文件 $TARGET_FILE 不存在！"
else
    # 追加内容
    echo "$APPEND_CONTENT" >> "$TARGET_FILE"
    # 提示成功
    echo "✅ 成功将 VS Code Server PATH 配置追加到 $TARGET_FILE"
fi
