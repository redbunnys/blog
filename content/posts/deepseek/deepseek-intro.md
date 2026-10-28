---
title: "DeepSeek 入门：从 V2 到 V4.1 的模型家族与选型指南"
date: 2026-10-05T10:20:00+08:00
tags: ["DeepSeek", "AI", "大模型"]
categories: ["AI"]
featured_image: "https://w.wallhaven.cc/full/w5/wallhaven-w5eq57.jpg"
description: "梳理 DeepSeek 的版本演进（V2/V3/R1/V3.1/V3.2/V4/V4.1）、当前 API 模型名、参数规模与选型建议"
comment : true
hidden: false
draft: false
---

DeepSeek 这两年的迭代速度很快，光看博客和朋友圈，很容易把 `deepseek-chat`、`deepseek-reasoner`、`deepseek-flash`、`deepseek-v4-pro` 这些名字搞混。本文按时间线把模型家族梳理一遍，并给出当前（2026 年 10 月）的选型建议。

## 一、先记住两个当前可用的模型名

截至 2026-10-17，DeepSeek API 上只有两个模型名需要记：

| 模型名 | 背后的具体版本 | 定位 | 上下文 / 最大输出 |
|---|---|---|---|
| `deepseek-flash` | DeepSeek-V4.1-Flash-1017 | 快、便宜、原生支持图片输入 | 1M / 384K |
| `deepseek-v4-pro` | DeepSeek-V4-Pro-0813 | 最强，Agent 与复杂推理 | 1M / 384K |

旧的 `deepseek-chat` 与 `deepseek-reasoner` 已于 2026-07-24 彻底下线（此前它们分别指向 V4-Flash 的非思考模式与思考模式）。`deepseek-v4-flash`、`deepseek-v4-flash-vision-exp` 作为兼容名称仍可调用，但已被路由到 V4.1-Flash 并按 Flash 价格计费。

两个模型都默认开启思考模式（thinking），也可以关掉，用参数控制，见后文的《思考模式》一文。

## 二、版本演进时间线

| 时间 | 版本 | 关键变化 |
|---|---|---|
| 2024-05 | DeepSeek-V2 | MLA（多头潜在注意力）+ DeepSeekMoE，开创"高性能 + 低价"路线 |
| 2024-08 | 上下文硬盘缓存 | 前缀命中部分按缓存价计费，成本再降一个量级 |
| 2024-09 | DeepSeek-V2.5 | Chat 与 Coder 双模型合并，`deepseek-coder` 与 `deepseek-chat` 指向同一模型 |
| 2024-12-26 | DeepSeek-V3 | 671B 总参数 / 37B 激活参数，FP8 训练 + MTP 多 token 预测 |
| 2025-01-20 | DeepSeek-R1 | 用大规模强化学习（GRPO 路线）做纯推理模型，开源权重引发全球关注 |
| 2025-03-24 | V3-0324 | MMLU-Pro 75.9→81.2，AIME 39.6→59.4，函数调用准确率修复 |
| 2025-05-28 | R1-0528 | AIME 2025 70.0→87.5，幻觉显著下降，支持 JSON 输出与函数调用 |
| 2025-08-21 | V3.1 | 混合推理架构：一个模型同时支持思考 / 非思考两种模式 |
| 2025-09-22 | V3.1-Terminus | 修复中英混输与异常字符，优化 Code Agent / Search Agent |
| 2025-09-29 | V3.2-Exp | 引入 DSA（DeepSeek Sparse Attention）稀疏注意力，大幅降价 |
| 2025-12-01 | V3.2 / Speciale | V3.2 正式版；Speciale 为限时高算力版本 |
| 2026-04-24 | DeepSeek-V4 Preview | V4-Pro 1.6T 总参数 / 49B 激活；V4-Flash 284B / 13B；1M 上下文成为标准 |
| 2026-07-31 | V4-Flash 0731 | 正式版发布，Agent 能力大幅提升，原生支持 Responses API |
| 2026-08-13 | V4-Pro GA | Agent 能力升级，支持低/高/最高三档思考强度，开始峰谷定价 |
| 2026-08-21 | V4-Flash-Vision-Exp | 实验性多模态视觉理解模型 |
| 2026-09-10 | V4.1-Flash | 新一代架构家族中最小模型，原生多模态，模型名统一为 `deepseek-flash` |
| 2026-10-17 | V4.1-Flash-1017 + Search API | 性价比再优化；官方开放自研搜索引擎的 Search / Fetch API |

从这条线能看出两个规律：

1. **架构创新换价格**：MLA、DeepSeekMoE、FP8、DSA 每一代都在降单位 token 成本，"开源 + 低价"是始终不变的主线。
2. **从"两个模型"回归"一个模型两种模式"**：R1 时代需要 chat / reasoner 两个入口，V3.1 之后合并为同一个模型，用参数切换思考模式，V4 延续至今。

## 三、V4 的架构要点（不用背，但要理解影响）

- **参数规模**：V4-Pro 1.6T 总参数 / 49B 激活，V4-Flash 284B 总参数 / 13B 激活，都是 MoE。
- **注意力**：Token 级压缩 + DSA 稀疏注意力，把长上下文的计算和显存开销压下来，1M 上下文才可能成为默认配置。
- **Agent 导向**：官方明确说 V4 针对 Claude Code、OpenCode、OpenClaw 等 Agent 工具做过适配，Terminal-Bench、DeepSWE、NL2Repo 这类 Agent 基准也是主要宣传口径。
- **多模态**：V4.1-Flash 原生支持图片理解，V4-Pro 目前只接受文本。

理解这一点对工程实践的意义是：**长文档、长对话、仓库级代码理解，现在真的可以一次塞进 1M 上下文里，而不用先做 RAG 切分**。但塞得越多，输入 token 越贵，缓存和上下文裁剪依然要设计。

## 四、怎么选

| 场景 | 推荐 | 理由 |
|---|---|---|
| 日常问答、翻译、写作、草稿 | `deepseek-flash` + 非思考模式 | 最便宜，延迟最低 |
| 需要读懂截图、图表、PDF 图片 | `deepseek-flash` | 目前唯一支持视觉输入的模型 |
| 代码补全、批量重构、脚本生成 | `deepseek-flash` 思考模式（high） | 单价约为 Pro 的 1/4，长任务性价比高 |
| 复杂数学推导、架构设计、疑难 Debug | `deepseek-v4-pro` 思考模式（max） | 能力上限最高 |
| 长链路 Agent（几十次工具调用） | `deepseek-v4-pro` 或 Flash 视预算 | Pro 在 Terminal-Bench / Toolathlon 上更稳 |
| 每日跑批、离线数据清洗 | `deepseek-flash` + 谷时调度 | 谷时价格是峰时的一半 |

一个实用经验：**先用 Flash 跑通，再考虑换 Pro**。V4-Flash 在简单 Agent 任务上已经"与 V4-Pro 相当"，只有真正卡住的时候才需要加钱。

## 五、快速验证

拿到 API Key 后，最小验证只需要一行 curl：

```bash
curl https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DEEPSEEK_API_KEY}" \
  -d '{
    "model": "deepseek-flash",
    "messages": [{"role": "user", "content": "用一句话解释 MoE"}],
    "thinking": {"type": "disabled"}
  }'
```

返回体里的 `usage` 会告诉你花了多少 token，以及其中多少命中了缓存：

```json
"usage": {
  "prompt_tokens": 18,
  "completion_tokens": 42,
  "prompt_cache_hit_tokens": 0,
  "prompt_cache_miss_tokens": 18
}
```

下一篇会讲 API 的完整用法：OpenAI / Anthropic 两种协议、流式输出、JSON 输出、前缀续写与 FIM 补全。

> 说明：本文的版本信息与价格均来自 DeepSeek 官方文档（api-docs.deepseek.com）与变更日志，价格会调整，以官方页面为准。
