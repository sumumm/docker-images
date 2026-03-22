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

# 将 VSCode 默认终端配置从 zsh 改为 bash
# sed 表达式说明：s/旧值/新值/g
#   - 匹配 "terminal.integrated.defaultProfile.linux": "zsh"
#   - 替换为 "terminal.integrated.defaultProfile.linux": "bash"
#   - g 标志表示全局替换（一行中所有匹配项）
sed_expr='s/"terminal\.integrated\.defaultProfile\.linux": "zsh"/"terminal.integrated.defaultProfile.linux": "bash"/g'
# 需要修改的 VSCode 设置文件路径列表
settings_files=(
    /root/.vscode-server/data/Machine/settings.json
    /root/.local/share/code-server/Machine/settings.json
)
for f in "${settings_files[@]}"; do
    if [ -f "$f" ]; then
        if sed -i "$sed_expr" "$f"; then
            echo "✅ 已更新 $f"
        else
            echo "❌ 更新 $f 失败"
        fi
    fi
done

echo "✅ 成功配置全局 bash 环境"
