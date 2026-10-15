#!/usr/bin/env bash
# 恢复 wx-bot 系统服务 (因 /etc/systemd/system 是易失的,虚拟机回收后需重建)
# 用法: bash ~/workspace/wx-bot/restore-service.sh
set -euo pipefail
SRC="$HOME/.config/systemd/user/wx-bot.service"
DST="/etc/systemd/system/wx-bot.service"
if [ ! -f "$SRC" ]; then echo "源文件不存在: $SRC"; exit 1; fi
cp "$SRC" "$DST"
sed -i 's|%h|/home/hatch|g' "$DST"
systemctl daemon-reload
systemctl enable --now wx-bot.service
echo "wx-bot 服务已恢复: $(systemctl is-active wx-bot.service)"
