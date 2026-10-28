---
title: "DeepSeek API 快速上手：OpenAI / Anthropic 双协议实战"
date: 2026-10-09T21:05:00+08:00
tags: ["DeepSeek", "API", "AI"]
categories: ["AI"]
featured_image: "https://w.wallhaven.cc/full/qr/wallhaven-qrjmgl.jpg"
description: "从零调用 DeepSeek API：OpenAI 与 Anthropic 两种协议、流式输出、JSON 输出、前缀续写、FIM 补全与常见坑"
comment : true
hidden: false
draft: false
---

DeepSeek API 的设计哲学很务实：**协议完全兼容 OpenAI / Anthropic**，所以你几乎不需要改代码，只改 `base_url`、`api_key`、`model` 三个值。这篇文章把常用能力过一遍，并记下几个实际踩过的坑。

## 一、三个必须改的参数

| 参数 | OpenAI 格式 | Anthropic 格式 |
|---|---|---|
| base_url | `https://api.deepseek.com` | `https://api.deepseek.com/anthropic` |
| api_key | 控制台申请，`sk-` 开头 | 同左 |
| model | `deepseek-flash` / `deepseek-v4-pro` | 同左 |

API Key 在 [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys) 申请。建议一律用环境变量注入，别硬编码：

```bash
export DEEPSEEK_API_KEY="sk-xxxxxx"
```

## 二、Python：OpenAI SDK 三行接入

```python
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["DEEPSEEK_API_KEY"],
    base_url="https://api.deepseek.com",
)

resp = client.chat.completions.create(
    model="deepseek-flash",
    messages=[
        {"role": "system", "content": "你是一个严谨的运维助手，回答简洁。"},
        {"role": "user", "content": "nginx 502 一般怎么排查？"},
    ],
)
print(resp.choices[0].message.content)
```

如果你要控制思考模式，注意 `thinking` 不是 OpenAI SDK 的标准字段，必须塞进 `extra_body`：

```python
resp = client.chat.completions.create(
    model="deepseek-flash",
    messages=messages,
    reasoning_effort="high",                    # low / high / max
    extra_body={"thinking": {"type": "enabled"}},  # 默认就是 enabled
)
```

关掉思考：

```python
extra_body={"thinking": {"type": "disabled"}}
```

## 三、流式输出

```python
stream = client.chat.completions.create(
    model="deepseek-flash",
    messages=messages,
    stream=True,
    extra_body={"thinking": {"type": "disabled"}},
)

for chunk in stream:
    delta = chunk.choices[0].delta
    if delta.content:
        print(delta.content, end="", flush=True)
```

思考模式下流式返回时，思维链在 `delta.reasoning_content` 里，正文在 `delta.content` 里，两者要分开处理（前端一般把 reasoning 折叠展示）。

## 四、Anthropic 格式：给 Claude Code 之类工具用

Anthropic 协议的路径是 `/anthropic`，思考模式用 `reasoning.effort` 控制，`none` 即关闭：

```python
import anthropic

client = anthropic.Anthropic(
    api_key=os.environ["DEEPSEEK_API_KEY"],
    base_url="https://api.deepseek.com/anthropic",
)

msg = client.messages.create(
    model="deepseek-flash",
    max_tokens=2048,
    system="你是一个 Go 语言专家。",
    messages=[{"role": "user", "content": "解释一下 sync.Pool 的适用场景"}],
    reasoning={"effort": "high"},
)
print(msg.content[0].text)
```

记住 Anthropic 格式的三个控制项：

| 目的 | 参数 |
|---|---|
| 关闭思考 | `reasoning.effort = "none"` |
| 思考强度 | `output_config.effort = "low" / "high" / "max"` |
| 回复长度上限 | `max_tokens`（必填风格，建议显式给） |

## 五、JSON 输出

需要结构化结果（比如让模型输出告警分类）时，用 `response_format`：

```python
resp = client.chat.completions.create(
    model="deepseek-flash",
    messages=[
        {"role": "system", "content": "你是一个日志分类器，只输出 JSON。"},
        {"role": "user", "content": "ERROR: connection refused to 10.0.0.5:5432"},
    ],
    response_format={"type": "json_object"},
    extra_body={"thinking": {"type": "disabled"}},
)
print(resp.choices[0].message.content)
```

两个要点：

1. `prompt` 里必须出现 "json" 字样并描述字段结构，否则可能返回空对象。
2. 仍然要做容错：加 `try/except json.loads`，失败时重试或降级为正则提取。

## 六、前缀续写（Chat Prefix Completion）

想让模型从你给定的开头继续写（比如生成 SQL 后固定加 `LIMIT 100`），把最后一条 assistant 消息用 `prefix=True` 标记：

```python
messages = [
    {"role": "user", "content": "把这条需求翻译成 PostgreSQL 查询：最近 7 天每天的订单量"},
    {"role": "assistant", "content": "```sql\nSELECT", "prefix": True},
]

resp = client.chat.completions.create(
    model="deepseek-flash",
    messages=messages,
    extra_body={"thinking": {"type": "disabled"}},
)
print(resp.choices[0].message.content)
```

## 七、FIM 补全：做代码补全插件用

FIM（Fill-In-the-Middle）走 `/completions` 端点，不是 `/chat/completions`，并且**只在非思考模式下可用**：

```python
resp = client.completions.create(
    model="deepseek-flash",
    prompt="def parse_config(path: str) -> dict:\n    ",
    suffix="\n\n# 调用示例\ncfg = parse_config('a.toml')",
    max_tokens=256,
)
print(resp.choices[0].text)
```

`suffix` 就是光标后面的代码，模型会补中间那一段。这是 IDE 插件的标准用法。

## 八、几个实际踩过的坑

**1. 名字写错导致静默降级**
`deepseek-v4-flash` 之类旧名仍能调用，但实际被路由到 V4.1-Flash。如果你在对比实验，务必确认日志里打的是真实模型名，否则会得出"两个模型表现一样"的错误结论。

**2. 思考模式下 temperature 完全无效**
设置 `temperature`、`presence_penalty`、`frequency_penalty` 不会报错，但也不会有任何效果。要"稳定输出"，用非思考模式 + `temperature=0`，或者干脆约束 prompt。

**3. 带 tools 时必须回传 reasoning_content**
这是最常见的 400 错误来源，下一篇专门讲。

**4. 超时与重试**
1M 上下文 + max 思考强度的请求可能跑很久，客户端超时要放宽（建议 300s 以上），并对 429 / 5xx 做指数退避重试；4xx（除 429）不要重试。

**5. 并发限制**
官方按账号限制并发：`deepseek-flash` 2500、`deepseek-v4-pro` 500。批量任务要自己做信号量或队列，别一把梭。

## 九、最小可用的封装

```python
import os, time
from openai import OpenAI, APIError, RateLimitError

client = OpenAI(api_key=os.environ["DEEPSEEK_API_KEY"],
                base_url="https://api.deepseek.com", timeout=300)

def chat(prompt: str, system: str = "你是一个严谨的助手。",
         model: str = "deepseek-flash", thinking: bool = False,
         effort: str = "high", retries: int = 3) -> str:
    body = {"type": "enabled" if thinking else "disabled"}
    for i in range(retries):
        try:
            resp = client.chat.completions.create(
                model=model,
                messages=[{"role": "system", "content": system},
                          {"role": "user", "content": prompt}],
                reasoning_effort=effort,
                extra_body={"thinking": body},
            )
            return resp.choices[0].message.content
        except (RateLimitError, APIError) as e:
            if i == retries - 1:
                raise
            time.sleep(2 ** i)
```

后续两篇分别深入思考模式和成本优化，最后一篇讲怎么把它接到 Claude Code / Codex 这类 Agent 工具上。
