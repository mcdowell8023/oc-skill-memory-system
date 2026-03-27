# openclaw-skill-memory-system

OpenClaw 记忆系统完整配置技能。解决 AI 失忆问题：配置本地 embedding 语义搜索 + Obsidian CLI 降级 + 心跳日记写入保障 + diarist 专职日记角色。

## 角色名说明

本 Skill 使用两个角色概念，**名称可自定义**：

| 概念 | 默认英文名 | 推荐中文名（可选） | 职责 |
|------|-----------|-----------------|------|
| coordinator | coordinator | 万三 | 总控调度，接收任务、派发、汇总 |
| diarist | diarist | 纪昀 | 专职日记写入，记忆保障 |

在你的 AGENTS.md 中，用任意名字注册这两个角色即可。

## 触发条件
- 用户提到「记忆系统」「memory search」「AI 失忆」「memory_search 不工作」
- 新装机器首次配置 OpenClaw 记忆功能
- 用户说「配置记忆」「设置记忆系统」

## 执行步骤

1. 运行 `scripts/setup.sh` — 配置 local embedding + memorySearch
2. 验证：`scripts/health-check.sh` — 确认索引正常、搜索可用
3. （可选）安装 Obsidian CLI 降级链路
4. 配置 HEARTBEAT.md 心跳日记写入规则（使用 references/heartbeat-template.md）
5. 在 AGENTS.md 中注册 diarist 角色（见下方规格，角色名可自定义）
6. 验证：`scripts/self-test.sh` — 全部通过后完成

## 记忆模式切换

用户可随时说以下口令切换检索方式：
- `记忆模式：语义` — memory_search 向量搜索（默认）
- `记忆模式：全文` — obsidian search 关键词检索
- `记忆模式：直读` — 直接读取 memory/*.md 文件

切换时写入 `memory-mode.txt`，并主动告知用户。

## 降级策略

### 何时降级
- memory_search 报错 / 超时 / 模型加载失败 → 自动切换全文模式
- 0 结果且 query 关键词明确 → 建议并行 obsidian search（不自动判定索引损坏）

### 恢复机制（冷却恢复，防抖）
- 降级后记录时间戳
- 每次查询前检查：距降级 > 10 分钟？→ 重试 memory_search 一次
- 成功 → 切回语义模式，更新 memory-mode.txt
- 失败 → 重置计时器，继续 fallback

### 统一返回格式
两种检索方案均映射到同一结构，调用方只需处理一种格式：

```json
{
  "content": "命中文本",
  "file": "来源文件路径",
  "score": 0.72,
  "source": "vector | obsidian | direct"
}
```
全文检索时 score 为 null，source 标记来源链路。

## 心跳日记写入格式（Obsidian 双链规范）

```markdown
### HH:MM #项目标签 #子标签

**时间戳：** YYYY-MM-DD HH:MM
**事件：** 发生了什么（客观描述，1-3句）
**决策：** 确认/选择了什么（结论，可为空）
**影响：** 下步行动 / 待办 / 阻塞（[[双链]] 引用相关文件）

相关：[[YYYY-MM-DD]] [[相关文档名]]
```

**双链规范：**
- `[[文件名]]` — 引用相关文件，建立图谱关系
- `#标签` — 按项目/类型分类，obsidian search 可过滤
- `相关：[[日期]]` — 跨日记关联，恢复上下文

## diarist 角色规格（专职日记 sub-agent）

### 基本信息
- 角色名：diarist（日记员，可自定义，建议中文名「纪昀」）
- 模型：`claude-haiku-4.5`（备选：`gpt-5-mini`）
- 架构：正式 sub-agent，走标准 spawn/完成流程
- 职责：专职日记写入，不产出面向用户内容

### 触发规则（coordinator 步骤 8）

coordinator 工作流固定步骤 8：审核汇总完成 → spawn diarist → 再回复用户

触发条件（任一满足）：
- 子代理 completion event 到达后
- 重大决策落地
- coordinator 主动判断值得记

### 分工边界

| 角色 | 写入目标 | 内容 |
|------|---------|------|
| coordinator | `status.json` | 当前任务状态、进度 |
| diarist | `memory/YYYY-MM-DD.md` | 事件日记，长期记忆原料 |

### diarist task 模板

```
你是纪昀（diarist），专职写日记，不做其他任何事。

**写入策略（优先级顺序）：**
1. 首选：用 write 工具直接追加到 ~/.openclaw/workspace/memory/YYYY-MM-DD.md（最可靠）
2. 备选：obsidian CLI（需要 Obsidian 正在运行）

执行命令（obsidian CLI 备选，Linux 必须加 --no-sandbox）：
obsidian --no-sandbox vault="workspace" append file="memory/YYYY-MM-DD" content="[四格内容]"

四格格式（content 的值）：
### HH:MM #标签
**时间戳：** ...
**事件：** ...
**决策：** ...
**影响：** ... [[双链]]
相关：[[YYYY-MM-DD]]

content 中换行用 \n，不要用真实换行。

写完后执行：openclaw memory index 2>&1 | tail -3
最多 3 个工具调用，完成后返回 NO_REPLY（不打扰主会话）
```

## Obsidian Vault 配置

要让 Obsidian CLI 能搜索 Agent 的记忆文件，必须将以下两个目录都加入 vault：

| Vault 名 | 路径 | 内容 |
|---------|------|------|
| `doc` | `~/open-claw-output/doc/` | 对外文档、知识文章 |
| `workspace` | `~/.openclaw/workspace/` | 记忆日记、AGENTS.md、projects/ |

配置方法：编辑 `~/.config/obsidian/obsidian.json`，在 `vaults` 对象中新增条目：
```json
"随机8位key": {
  "path": "/home/用户名/.openclaw/workspace",
  "ts": 当前时间戳毫秒,
  "open": false
}
```

> Vault 名称 = 路径最后一段目录名（`workspace`、`doc`）

**为什么两个都要加：** obsidian search 只能搜 vault 内文件，workspace 不加则记忆日记无法被全文检索。

## 文档书写规范（双轨制）

- **内部知识库**（存 vault）→ 使用 `obsidian create` 写入，加 `[[双链]]` + `#标签` + YAML frontmatter
- **对外交付/飞书** → 标准 Markdown，不加双链

内部文档 frontmatter 模板：
```yaml
---
tags: [项目名, 类型]
created: YYYY-MM-DD
related: [[关联文档名]]
---
```

页脚模板：
```
---
标签：#标签1 #标签2
相关：[[文档A]] [[文档B]]
```

## Skill 使用规则

此 Skill 必须在以下场景中显式加载，不得用 write/exec 绕过：

| 场景 | 命令 |
|------|------|
| 追加日记内容 | `obsidian --no-sandbox vault="workspace" append file="memory/YYYY-MM-DD" content="..."` |
| 创建新知识文档 | `obsidian --no-sandbox vault="workspace" create name="文档名" content="..."` |
| 全文搜索记忆 | `obsidian --no-sandbox vault="workspace" search query="关键词"` |
| 创建对外文档 | `obsidian --no-sandbox vault="doc" create name="文档名" content="..."` |

## 已知漏洞与修复记录

### 漏洞1：工作结束后未 spawn diarist（2026-03-24 确认）
- **现象：** 大量子代理串行工作后，coordinator 汇报用户时忘记步骤8（spawn diarist），导致整日记录丢失
- **修复：** AGENTS.md 强化步骤8为硬性规则；增加每日22:00 cron 兜底检查

### 漏洞2：diarist 依赖 obsidian CLI，Obsidian 未启动时静默失败
- **现象：** diarist spawn 成功但写入失败，无错误提示
- **修复：** diarist task 模板改为优先用 `write` 工具直接写文件，obsidian CLI 作为备选

### 修复措施汇总（2026-03-27）
1. **HEARTBEAT.md 加 Premium 低电量保护**：<20% 强制写日记，=0% 万三直接写不 spawn
2. **每日22:00 cron 兜底检查**：检查日记完整性、重建索引、测试搜索可用性
3. **diarist 写入降级**：write 工具 → obsidian CLI，不再单一依赖 CLI

---

## 已知局限

- `embeddinggemma-300M` 中文语义能力有限，专有名词/日期/短 query 建议用全文检索
- 1GB RAM 以下设备可能 OOM，建议低配机直接用 Obsidian CLI 方案
- FTS5 在本机 Node.js 环境不可用，全文检索走 Obsidian CLI

## 相关文档

- `references/diary-format.md` — 日记格式完整规范
- `references/heartbeat-template.md` — HEARTBEAT.md 模板
- `scripts/setup.sh` — 一键配置脚本
- `scripts/health-check.sh` — 健康检查
- `scripts/self-test.sh` — 自测脚本
