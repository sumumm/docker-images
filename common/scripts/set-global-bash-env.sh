#!/usr/bin/env bash

# 全局 bash 配置（所有用户自动加载）
cat >> /etc/bash.bashrc << 'EOF'

# 安全地设置 VS_CODE_PATH,兼容未安装 VS Code Server 的情况
code_path=$(find "$HOME/.vscode-server/cli/servers" -name "code" -path "*/remote-cli/*" 2>/dev/null | head -1)

if [ -n "$code_path" ] && [ -f "$code_path" ]; then
    export VS_CODE_PATH="$(dirname "$code_path")"
fi

# 如果找到了，就把它的上级目录加入到 PATH 中
if [ -n "$VS_CODE_PATH" ]; then
    export PATH="$VS_CODE_PATH:$PATH"
fi

# Git 补全和提示（全局配置）
if [ -f /usr/local/share/bash/git-completion.bash ]; then
    source /usr/local/share/bash/git-completion.bash
fi
if [ -f /usr/local/share/bash/git-prompt.bash ]; then
    source /usr/local/share/bash/git-prompt.bash
    set_git_ps1
fi
EOF

echo "✅ 成功配置全局 bash 环境"
