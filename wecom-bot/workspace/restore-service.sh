#!/usr/bin/env bash
# 恢复 wecom-bot 系统服务 (因 /etc/systemd/system 是易失的,虚拟机回收后需重建)
# 用法: bash ~/workspace/wecom-bot/restore-service.sh
set -euo pipefail
SRC="$HOME/.config/systemd/user/wecom-bot.service"
DST="/etc/systemd/system/wecom-bot.service"
if [ ! -f "$SRC" ]; then echo "源文件不存在: $SRC"; exit 1; fi
cp "$SRC" "$DST"
sed -i 's|%h|/home/hatch|g' "$DST"
systemctl daemon-reload
systemctl enable --now wecom-bot.service
echo "wecom-bot 服务已恢复: $(systemctl is-active wecom-bot.service)"
