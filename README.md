# Muse 消息桥 (双桥合集)

个人微信 (wx-bot) + 企业微信 (wecom-bot) 消息桥接，将消息转发给 Muse/Lux 处理。

## 架构

```
微信 <--iLink--> wx-bot (常驻服务) --> 本地 inbox --> hook 1秒轮询 --> worker 处理
企业微信 <--WebSocket--> wecom-bot (常驻服务) --> SQLite inbox --> hook 1秒轮询 --> worker 处理
```

## 目录结构

```
muse-bridges-pkg/
├── README.md
├── install.sh              # 一键安装双桥
├── wx-bot/                 # 微信桥
│   ├── bin/wx-bot          # 主程序 (Go 二进制, v0.4.8)
│   ├── config/             # 配置模板
│   ├── systemd/            # systemd 服务
│   ├── hooks/              # hook 脚本与定义 (1秒轮询)
│   └── workspace/          # 服务恢复脚本
└── wecom-bot/              # 企业微信桥
    ├── bin/wecom-bot       # 主程序 (Python)
    ├── config/             # 配置模板 (需填 BotID/Secret)
    ├── systemd/            # systemd 服务
    ├── hooks/              # hook 脚本与定义 (1秒轮询)
    └── workspace/          # 服务恢复脚本
```

## 文件清单

| 桥 | 文件 | 安装位置 | 说明 |
|----|------|----------|------|
| wx-bot | bin/wx-bot | ~/.local/bin/wx-bot | 主程序 (Go, v0.4.8) |
| wx-bot | config/config.json.template | ~/.config/wx-bot/config.json | 配置模板 |
| wx-bot | systemd/wx-bot.service | ~/.config/systemd/user/ + /etc/systemd/system/ | systemd 服务 (双备份) |
| wx-bot | hooks/wechat-inbox.sh | ~/hooks/scripts/wechat-inbox.sh | hook 轮询脚本 (1秒) |
| wx-bot | workspace/restore-service.sh | ~/workspace/wx-bot/restore-service.sh | 服务恢复脚本 |
| wecom-bot | bin/wecom-bot | ~/.local/bin/wecom-bot | 主程序 (Python) |
| wecom-bot | config/config.json.template | ~/.config/wecom-bot/config.json | 配置模板 (填 BotID/Secret) |
| wecom-bot | systemd/wecom-bot.service | ~/.config/systemd/user/ + /etc/systemd/system/ | systemd 服务 (双备份) |
| wecom-bot | hooks/wecom-inbox.sh | ~/hooks/scripts/wecom-inbox.sh | hook 轮询脚本 (1秒) |
| wecom-bot | workspace/restore-service.sh | ~/workspace/wecom-bot/restore-service.sh | 服务恢复脚本 |

## 延时说明

- Hook 轮询间隔：1 秒 (双桥均已优化)
- 简单问答：wecom-bot 桥内 2 秒快路径直接回复
- 复杂问题：唤醒 worker 处理，全程 15–30 秒 (轮询架构的延迟天花板)

## 已知要点

1. `/etc/systemd/system/` 在虚拟机回收时丢失，服务文件需双备份；掉线后跑对应 restore-service.sh 恢复
2. wx-bot 首次使用需扫码登录；登录态丢失时需重新扫码
3. wecom-bot 需在企微后台创建智能机器人获取 BotID/Secret
4. 回复微信只发纯文本，不要 Markdown

## 版本

- wx-bot v0.4.8 (2026-10-13)
- wecom-bot (Python, 2026-10-14)
- 本包：2026-10-15 (含 1 秒轮询优化)

## 完整包下载 (含 wx-bot 二进制)

- **Google Drive**: [muse-bridges-v1.tar.gz](https://drive.google.com/file/d/1QfKxYv2wXYZ1234567890/view) (35MB, 链接待更新)

```bash
tar xzf muse-bridges-v1.tar.gz
cd muse-bridges-pkg && bash install.sh
```
