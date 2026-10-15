#!/usr/bin/env bash
set -euo pipefail
source "$HATCH_HOOK_RUNTIME"

WXBOT="$HOME/.local/bin/wx-bot"
BINDING="muse"
MARK="$HOME/.cache/wx-bot/hook-alerted"

if ! count="$("$WXBOT" inbox count --binding "$BINDING" 2>&1)"; then
    silent "wx-bot count 查询失败"
    exit 0
fi
if [ "$count" -gt 0 ]; then
    wake "微信有 $count 条新事件"
    exit 0
fi

if health="$("$WXBOT" health --binding "$BINDING" --liveness 2>&1)"; then
    rm -f "$MARK"
    silent "wx-bot 正常，无新消息"
elif [ -f "$MARK" ] && [ -z "$(find "$MARK" -mmin +60 2>/dev/null)" ]; then
    silent "wx-bot 异常已在1小时内提醒过"
else
    mkdir -p "$(dirname "$MARK")"
    touch "$MARK"
    wake "wx-bot 异常：$health"
fi
