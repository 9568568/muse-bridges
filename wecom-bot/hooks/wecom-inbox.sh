#!/usr/bin/env bash
set -euo pipefail
source "$HATCH_HOOK_RUNTIME"
WXBOT="$HOME/.local/bin/wecom-bot"
MARK="$HOME/.cache/wecom-bot/hook-alerted"
if ! count="$("$WXBOT" inbox count 2>&1)"; then
    silent "wecom-bot count 查询失败"
    exit 0
fi
if [ "$count" -gt 0 ]; then
    wake "企微有 $count 条新消息"
    exit 0
fi
if health="$("$WXBOT" health 2>&1)"; then
    rm -f "$MARK"
    silent "wecom-bot 正常，无新消息"
elif [ -f "$MARK" ] && [ -z "$(find "$MARK" -mmin +60 2>/dev/null)" ]; then
    silent "wecom-bot 异常已在1小时内提醒过"
else
    mkdir -p "$(dirname "$MARK")"
    touch "$MARK"
    wake "wecom-bot 异常：$health"
fi
