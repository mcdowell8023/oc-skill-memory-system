# Obsidian CLI on Linux / Ubuntu 24.04

## 问题

Ubuntu 24.04 上运行 Obsidian CLI 会报错：

```
FATAL: The SUID sandbox helper binary is not configured correctly.
```

根因：Electron 沙箱机制在非 root 环境下需要 SUID 权限，Ubuntu 24.04 默认限制了这个权限。

## 解决方案

运行所有 obsidian 命令时加两个参数：

```bash
obsidian --no-sandbox --ozone-platform=x11 <subcommand>
```

- `--no-sandbox`：禁用 Electron 沙箱（Ubuntu 必须）
- `--ozone-platform=x11`：强制 X11 渲染（防止 Wayland 兼容性问题）

## 安装 Obsidian AppImage（推荐方式）

```bash
# 1. 安装 fuse2（AppImage 依赖）
sudo apt install libfuse2t64

# 2. 下载 AppImage
wget -O ~/Downloads/Obsidian.AppImage \
  https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian-1.12.4.AppImage

# 3. 赋予执行权限
chmod +x ~/Downloads/Obsidian.AppImage

# 4. 创建启动脚本（加 --no-sandbox）
cat > ~/.local/bin/obsidian << 'EOF'
#!/bin/bash
exec ~/Downloads/Obsidian.AppImage --no-sandbox --ozone-platform=x11 "$@"
EOF
chmod +x ~/.local/bin/obsidian

# 5. 验证
obsidian --no-sandbox vaults
```

## 配置 CLI 模式

1. 打开 Obsidian 图形界面
2. 设置 → 通用 → 高级 → 命令行界面 → 开启（紫色）
3. 验证：`obsidian --no-sandbox search query="test" vault="your-vault-name"`

## Autostart（让 Obsidian 在后台常驻）

OpenClaw CLI search 需要 Obsidian 进程在后台运行：

```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/obsidian.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Obsidian
Exec=/home/USERNAME/Downloads/Obsidian.AppImage --no-sandbox --ozone-platform=x11
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

将 `USERNAME` 替换为你的用户名。
