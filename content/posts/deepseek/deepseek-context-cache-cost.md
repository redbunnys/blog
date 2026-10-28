---
title: "DeepSeek 上下文缓存与峰谷定价：把 API 成本压下来"
date: 2026-10-19T20:15:00+08:00
tags: ["DeepSeek", "API", "成本优化"]
categories: ["AI"]
featured_image: "https://w.wallhaven.cc/full/5g/wallhaven-5g22q5.png"
description: "硬盘上下文缓存的命中规则、prompt_cache_hit_tokens 监控、峰谷时段调度与一份可落地的省钱清单"
comment : true
hidden: false
draft: false
---

同样一句问题，不同的调用方式，账单可能差一个数量级。DeepSeek 的价格体系里有两个杠杆特别好用：**上下文缓存（硬盘 KV 缓存）** 和 **峰谷时段**。这篇把规则讲清楚，并给一套能直接抄的省钱清单。

## 一、当前价格表（2026-10，单位：美元 / 1M tokens）

| | deepseek-flash 谷时 | deepseek-flash 峰时 | v4-pro 谷时 | v4-pro 峰时 |
|---|---|---|---|---|
| 输入（缓存命中） | $0.003 | $0.006 | $0.022 | $0.044 |
| 输入（缓存未命中） | $0.15 | $0.30 | $0.66 | $1.32 |
| 输出 | $0.60 | $1.20 | $1.98 | $3.96 |

三个立刻能看出来的结论：

1. **缓存命中的输入是未命中的 1/50**。命中率比模型选型更能决定成本。
2. **峰时价格是谷时的 2 倍**，峰时定义为 UTC 周一至周五 01:00–04:00 与 06:00–10:00（北京时间 09:00–12:00 与 14:00–18:00）；周末与中国法定节假日全天为谷时。
3. **输出是输入的 4 倍**（谷时），所以控制输出长度（含思维链长度）同样关键。

## 二、缓存是怎么命中的

DeepSeek 的上下文缓存是**硬盘缓存**，默认对所有用户开启，不需要改代码。但它的命中规则比"前缀相同就命中"更严格：

> 缓存按 **cache prefix unit（缓存前缀单元）** 组织，后续请求只有**完整匹配**某个已持久化的前缀单元才算命中。

前缀单元在三种时机被持久化：

1. **请求边界**：每次请求都在"用户输入结束处"和"模型输出结束处"各生成一个前缀单元；
2. **公共前缀检测**：系统发现多条请求共享同一前缀时，把该公共前缀单独持久化为一个单元；
3. **固定 token 间隔**：长输入 / 长输出会按固定间隔切出单元，避免超长前缀永远等不到结束位置而全部无法命中。

### 两个例子

**例 1：多轮对话（会命中）**

第一轮：`A + B`
第二轮：`A + B + C`
→ 第二轮完整匹配第一轮的单元 `A + B`，**命中**。

**例 2：同一份长文档的多次提问（第一次不命中，第三次命中）**

第一轮：`系统提示 + 财报全文 + "总结要点"`
第二轮：`系统提示 + 财报全文 + "分析盈利能力"`
→ 两轮都**不命中**（`A+B` 与 `A+C` 不构成完整匹配），但系统会检测出公共前缀 `A` 并持久化。第三轮 `A + D` 就能命中 `A`。

这就是为什么**"同一份文档反复提问"比"每次换文档"便宜得多**——第一次是投资，后面才是收益。

## 三、怎么监控命中情况

响应体 `usage` 里有两个字段：

```json
"usage": {
  "prompt_tokens": 12030,
  "completion_tokens": 380,
  "prompt_cache_hit_tokens": 11800,
  "prompt_cache_miss_tokens": 230
}
```

命中率 = `prompt_cache_hit_tokens / prompt_tokens`。建议在业务里直接把这两个数打到日志或监控里：

```python
def log_usage(resp, tag=""):
    u = resp.usage
    hit = getattr(u, "prompt_cache_hit_tokens", 0)
    miss = getattr(u, "prompt_cache_miss_tokens", 0)
    total = hit + miss
    rate = hit / total * 100 if total else 0.0
    print(f"[{tag}] in={u.prompt_tokens} out={u.completion_tokens} "
          f"cache_hit={hit} cache_miss={miss} hit_rate={rate:.1f}%")
```

顺手估一下钱（以 flash 谷时为例）：

```python
def cost_usd(u, peak=False):
    k = 2 if peak else 1
    hit  = getattr(u, "prompt_cache_hit_tokens", 0)
    miss = getattr(u, "prompt_cache_miss_tokens", 0)
    out  = u.completion_tokens
    return (hit * 0.003 + miss * 0.15 + out * 0.60) * k / 1_000_000
```

跑一段时间你会发现：**没有做缓存设计的 RAG / Agent，命中率往往不到 10%；把 prompt 结构调一调，能到 80% 以上。**

## 四、提高命中率的实操清单

**1. 稳定内容放前面，变量放后面**

缓存是前缀匹配，所以顺序决定一切：

```
✅ 指令 + 少样本示例 + 长文档  →  用户本轮问题
❌ 用户本轮问题 → 指令 + 示例 + 长文档
```

**2. 不要在系统提示开头插时间戳 / 随机 ID**

```python
# ❌ 每次请求前缀都不同，缓存全废
system = f"当前时间 {datetime.now()}，你是财报分析师……"

# ✅ 时间信息放到最后一条 user 消息里
system = "你是财报分析师……"
user   = f"（当前时间 {now}）问题：{q}"
```

同理，`request_id`、`session_id`、随机排序的少样本示例，都不要放进前缀区。

**3. 少样本示例顺序固定**

示例集合一样但顺序随机，等于前缀每次都变。要么固定顺序，要么把示例整体放到最后。

**4. 长文档按"文档"归组请求**

同样 100 次问答：分散在 100 份文档上 = 几乎零命中；集中在 3 份文档上 = 后 97 次基本全命中。批处理任务应先按文档聚合，再批量提问。

**5. 多轮对话别重建 messages**

每轮都从数据库重新拼 messages 时，注意拼接结果要**字节级一致**（同一个模板、同样的空格、同样的角色顺序）。手工拼容易多一个换行或少一个字段，命中率就掉了。

**6. 接受它只是"尽力而为"**

官方明确说缓存是 best-effort，不保证 100% 命中；缓存构建有秒级延迟，闲置后几小时到几天自动清理。所以不要把命中率当成正确性依赖，只能当成本优化。

## 五、峰谷调度：把批处理挪到谷时

峰时（UTC 周一至周五 01:00–04:00、06:00–10:00）价格翻倍。对离线任务来说，这是**免费的一半折扣**：

```python
from datetime import datetime, timezone

# 峰时窗口（UTC 小时），仅工作日
PEAK_WINDOWS = [(1, 4), (6, 10)]

def is_peak(now: datetime | None = None) -> bool:
    now = now or datetime.now(timezone.utc)
    if now.weekday() >= 5:           # 周六日全天谷时
        return False
    return any(start <= now.hour < end for start, end in PEAK_WINDOWS)

def run_batch(jobs):
    for job in jobs:
        if is_peak():
            print("峰时，暂停批处理，等待谷时窗口")
            time.sleep(600)
        handle(job)
```

注意中国法定节假日也算谷时，但节假日表要自己维护（或者干脆只按周末 + 时间窗判断，节假日的额外收益当意外之喜）。

## 六、输出端的省钱手段

| 手段 | 效果 |
|---|---|
| 简单任务关闭思考模式 | 省掉最贵的输出 token，通常省 50%~80% |
| 思考强度用 low 而非 max | 复杂任务也要慎用 max，输出长度涨幅很大 |
| `max_tokens` 显式限制 | 防止模型"话多"，尤其是 JSON 输出场景 |
| 要求先给结论再给细节 | 配合前端截断展示，不必生成长篇 |
| 结构化输出替代自然语言 | JSON 比"请详细说明"平均短 3~5 倍 |

## 七、一份完整的省钱组合拳

1. **选型**：默认 `deepseek-flash`，只有卡住才上 `deepseek-v4-pro`。
2. **思考**：默认关闭，代码/推理类用 `low`，疑难问题才 `high`/`max`。
3. **前缀**：稳定内容前置、去掉时间戳与随机 ID、少样本固定顺序。
4. **聚合**：长文档批量任务按文档归组，把"首问"当投资。
5. **调度**：离线任务全部挪到谷时窗口。
6. **监控**：日志里记录 `prompt_cache_hit_tokens` / `prompt_cache_miss_tokens` / `completion_tokens`，按天算钱。

做到这六条，同样的业务量，账单降到原来的 1/5 到 1/10 是很常见的。最后一个提示：**别为了省钱把 max_tokens 卡到输出被截断**，截断重试的成本远高于多写两百字。
