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

## 心跳日记写入格式（Obsidian 双链规范）

每次心跳写入时，必须使用以下格式：

```markdown
### HH:MM 心跳记录
#项目标签 #子标签

**决策：**
- xxx

**进展：**
- 完成：[[相关文件名]]
- 进行中：xxx

**阻塞：**
- xxx（原因）

**待办：**
- [ ] xxx

相关：[[YYYY-MM-DD]] [[相关文档名]]
```

**双链规范：**
- `[[文件名]]` — 引用相关文件，建立图谱关系
- `#标签` — 按项目/类型分类，obsidian search 可过滤
- `相关：[[日期]]` — 跨日记关联，恢复上下文

## 待实施优化项（Phase 4.1）

- **优化 A**：事件驱动写入（子代理完成时立即写，不等心跳）
- **优化 B**：四格强制格式（决策/进展/阻塞/待办）
- **优化 C**：写入后验证（读最后几行确认落盘）
- **优化 D**：摘要 vs 全量分离
- **优化 E**：Obsidian 双链格式（已实施，见上）
