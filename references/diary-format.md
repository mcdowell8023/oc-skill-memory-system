# 每日日记格式规范

日记文件路径：`~/.openclaw/workspace/memory/YYYY-MM-DD.md`

## 标准格式

```markdown
# YYYY-MM-DD 日记

## 会话概述
- 主要工作：xxx
- 关键决策：xxx

---

### HH:MM 心跳记录
#项目标签 #子标签

**决策：**
- xxx

**进展：**
- 完成：[[相关文件或项目名]]
- 进行中：xxx

**阻塞：**
- xxx（原因 + 等待什么）

**待办：**
- [ ] xxx

相关：[[YYYY-MM-DD]] [[相关文档名]]
```

## Obsidian 双链规范

### 双链 [[]]
用于引用相关文件，建立反向链接和图谱关系：
- 引用项目文档：`[[obsidian-cli-integration-architecture]]`
- 引用相关日记：`[[2026-03-18]]`
- 引用相关文档（用别名）：`[[项目设计文档]]`、`[[架构说明]]`

### 标签 #
用于按主题聚合，方便 obsidian search 过滤：
- 项目标签：`#记忆系统` `#Obsidian集成` `#Phase1` `#Phase4`
- 类型标签：`#决策` `#阻塞` `#完成`
- 常用标签组合：`#记忆系统 #Phase4 #完成`

### 无新增时
```markdown
### HH:MM 心跳：无新增
```

## 示例

```markdown
# 2026-03-19 日记

## 会话概述
- 主要工作：记忆系统完整实施（Phase 1-4）
- 关键决策：选用本地 embedding，Obsidian CLI 作降级

---

### 13:00 心跳记录
#记忆系统 #Phase4 #飞书

**决策：**
- 科普指南重构为四部分结构（问题/修复/进阶/运营）

**进展：**
- 完成：[[科普指南]] 飞书文档重写（69 blocks）
- 完成：[[openclaw-skill-memory-system]] 本地文件创建
- 完成：[[架构说明]] 新增附录 C、D

**阻塞：**
- GitHub 推送待用户授权（需 gh auth login 或 GITHUB_TOKEN）

**待办：**
- [ ] 心跳日记优化 A-E 落地

相关：[[YYYY-MM-DD]] [[架构说明]] [[项目设计文档]]
```
