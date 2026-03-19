# openclaw-skill-memory-system

OpenClaw 记忆系统完整配置技能。解决 AI 失忆问题：配置本地 embedding 语义搜索 + Obsidian CLI 降级 + 心跳日记写入保障。

## 触发条件
- 用户提到「记忆系统」「memory search」「AI 失忆」「memory_search 不工作」
- 新装机器首次配置 OpenClaw 记忆功能
- 用户说「配置记忆」「设置记忆系统」

## 执行步骤

1. 运行 `scripts/setup.sh` — 配置 local embedding + memorySearch
2. 验证：`scripts/health-check.sh` — 确认索引正常、搜索可用
3. （可选）安装 Obsidian CLI 降级链路
4. 配置 HEARTBEAT.md 心跳日记写入规则（使用 references/heartbeat-template.md）
5. 验证：`scripts/self-test.sh` — 全部通过后完成

## 记忆模式切换

用户可随时说以下口令切换检索方式：
- `记忆模式：语义` — memory_search 向量搜索（默认）
- `记忆模式：全文` — obsidian search 关键词检索
- `记忆模式：直读` — 直接读取 memory/*.md 文件

切换时写入 `memory-mode.txt`，并主动告知用户。

## 降级
当 memory_search 不可用时，参考 references/ 目录配置 Obsidian CLI 作为降级方案。
