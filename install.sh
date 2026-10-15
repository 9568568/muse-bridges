#!/usr/bin/env bash
# 双桥一键安装脚本 (wx-bot + wecom-bot)
# 用法: bash install.sh [--wx-only] [--wecom-only]
set -euo pipefail
PKGDIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_WX=true
INSTALL_WECOM=true
for arg in "$@"; do
  case "$arg" in
    --wx-only) INSTALL_WECOM=false ;;
    --wecom-only) INSTALL_WX=false ;;
  esac
done

install_wx() {
echo "=== 安装 wx-bot 微信消息桥 ==="
mkdir -p ~/.local/bin
cp "$PKGDIR/wx-bot/bin/wx-bot" ~/.local/bin/wx-bot
chmod 0755 ~/.local/bin/wx-bot

mkdir -p ~/.config/wx-bot && chmod 0700 ~/.config/wx-bot
if [ -f ~/.config/wx-bot/config.json ]; then
  echo "  配置已存在,备份为 config.json.bak"
  cp ~/.config/wx-bot/config.json ~/.config/wx-bot/config.json.bak
else
  cp "$PKGDIR/wx-bot/config/config.json.template" ~/.config/wx-bot/config.json
  chmod 0600 ~/.config/wx-bot/config.json
fi
[ -f ~/.config/wx-bot/env ] || { cp "$PKGDIR/wx-bot/config/env.template" ~/.config/wx-bot/env 2>/dev/null || true; chmod 0600 ~/.config/wx-bot/env 2>/dev/null || true; }

mkdir -p ~/.config/systemd/user
cp "$PKGDIR/wx-bot/systemd/wx-bot.service" ~/.config/systemd/user/wx-bot.service
cp ~/.config/systemd/user/wx-bot.service /etc/systemd/system/wx-bot.service 2>/dev/null || \
  sudo cp ~/.config/systemd/user/wx-bot.service /etc/systemd/system/wx-bot.service 2>/dev/null || true
sed -i 's|%h|'"$HOME"'|g' /etc/systemd/system/wx-bot.service 2>/dev/null || true

mkdir -p ~/hooks/scripts
cp "$PKGDIR/wx-bot/hooks/wechat-inbox.sh" ~/hooks/scripts/wechat-inbox.sh
chmod +x ~/hooks/scripts/wechat-inbox.sh

mkdir -p ~/workspace/wx-bot
cp "$PKGDIR/wx-bot/workspace/restore-service.sh" ~/workspace/wx-bot/restore-service.sh
chmod +x ~/workspace/wx-bot/restore-service.sh
echo "wx-bot 安装完成"
}

install_wecom() {
echo "=== 安装 wecom-bot 企业微信消息桥 ==="
mkdir -p ~/.local/bin
cp "$PKGDIR/wecom-bot/bin/wecom-bot" ~/.local/bin/wecom-bot
chmod 0755 ~/.local/bin/wecom-bot

mkdir -p ~/.config/wecom-bot && chmod 0700 ~/.config/wecom-bot
if [ -f ~/.config/wecom-bot/config.json ]; then
  echo "  配置已存在,备份为 config.json.bak"
  cp ~/.config/wecom-bot/config.json ~/.config/wecom-bot/config.json.bak
else
  cp "$PKGDIR/wecom-bot/config/config.json.template" ~/.config/wecom-bot/config.json
  chmod 0600 ~/.config/wecom-bot/config.json
  echo "  已创建 ~/.config/wecom-bot/config.json,请填入 BotID 和 Secret"
fi

mkdir -p ~/.config/systemd/user
cp "$PKGDIR/wecom-bot/systemd/wecom-bot.service" ~/.config/systemd/user/wecom-bot.service
cp ~/.config/systemd/user/wecom-bot.service /etc/systemd/system/wecom-bot.service 2>/dev/null || \
  sudo cp ~/.config/systemd/user/wecom-bot.service /etc/systemd/system/wecom-bot.service 2>/dev/null || true
sed -i 's|%h|'"$HOME"'|g' /etc/systemd/system/wecom-bot.service 2>/dev/null || true

mkdir -p ~/hooks/scripts
cp "$PKGDIR/wecom-bot/hooks/wecom-inbox.sh" ~/hooks/scripts/wecom-inbox.sh 2>/dev/null || true
chmod +x ~/hooks/scripts/wecom-inbox.sh 2>/dev/null || true

mkdir -p ~/workspace/wecom-bot
cp "$PKGDIR/wecom-bot/workspace/restore-service.sh" ~/workspace/wecom-bot/restore-service.sh
chmod +x ~/workspace/wecom-bot/restore-service.sh
echo "wecom-bot 安装完成"
}

$INSTALL_WX && install_wx
$INSTALL_WECOM && install_wecom

echo ""
echo "=== 安装完成 ==="
echo "后续步骤:"
$INSTALL_WX && echo "  wx-bot: systemctl daemon-reload && systemctl enable --now wx-bot.service (首次需扫码登录)"
$INSTALL_WECOM && echo "  wecom-bot: 1)填 ~/.config/wecom-bot/config.json 的 BotID/Secret 2)pip install websocket-client 3)systemctl enable --now wecom-bot.service"
echo "  在 Muse 中创建 hook (参考各桥 hooks/*.json, poll_interval_secs=1)"
