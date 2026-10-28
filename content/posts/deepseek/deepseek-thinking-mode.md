---
title: "DeepSeek 思考模式详解：reasoning_effort、reasoning_content 与带 tools 的坑"
date: 2026-10-14T22:40:00+08:00
tags: ["DeepSeek", "API", "推理模型"]
categories: ["AI"]
featured_image: "https://w.wallhaven.cc/full/3q/wallhaven-3qrdr6.jpg"
description: "从 R1 到 V4 的思考模式说明：默认开启、三档强度映射、思维链回传规则、多轮对话与工具调用的正确写法"
comment : true
hidden: false
draft: false
---

R1 时代，"思考模式"是一个独立模型 `deepseek-reasoner`；V3.1 之后它变成了同一个模型上的一个开关。这个变化带来两个后果：**调用更简单了，但也更容易用错**——尤其是思维链（`reasoning_content`）该不该回传这件事，官方文档里写得很清楚，实际代码里却经常写错。

## 一、思考模式是什么

开启后，模型先输出一段思维链（CoT），再输出最终答案：

```
reasoning_content: 用户问 9.11 和 9.8 谁大。要注意这是字符串比较的经典陷阱……
content:          9.8 更大。因为 9.11 = 9.11 < 9.8。
```

好处是复杂任务准确率明显提升；代价是输出 token 变多、延迟变长、**思维链 token 也计费**（按输出价计）。

## 二、开关与强度

默认是**开启**的，默认强度 `high`。

| 目的 | OpenAI 格式 | Anthropic 格式 | Responses API |
|---|---|---|---|
| 开关 | `{"thinking": {"type": "enabled/disabled"}}` | `{"reasoning": {"effort": "none/low/high/max"}}`（`none` 即关闭） | 见官方 Responses 指南 |
| 强度 | `{"reasoning_effort": "low/high/max"}` | `{"output_config": {"effort": "low/high/max"}}` | 同左风格 |

强度还会有别名映射，方便沿用其他框架的习惯值：

| 你传的值 | 实际生效 |
|---|---|
| minimal | low |
| low | low |
| medium | high |
| high | high |
| xhigh | high |
| max | max |
| ultra | max |

也就是说**只有 low / high / max 三档真实存在**，传 `medium` 等价于 `high`。

三档怎么选，我的实际经验：

| 任务 | 强度 | 说明 |
|---|---|---|
| 格式化、抽取字段、翻译 | 关闭思考 | 开了反而更慢更贵，还可能"想多了"改坏格式 |
| 日常代码、脚本、SQL | low 或 high | low 已经够用，快很多 |
| 复杂重构、架构方案对比 | high | 默认档，性价比最好 |
| 数学证明、疑难 bug、长链路 Agent | max | 明显更慢，只在真的卡住时用 |

**不要对所有请求都用 max**。max 的输出长度和耗时上升非常明显，日常任务用 max 是纯粹浪费预算。

## 三、思维链回传：唯一必须记住的规则

`reasoning_content` 在响应里和 `content` 同级返回：

```python
rc = resp.choices[0].message.reasoning_content
ans = resp.choices[0].message.content
```

回传规则取决于请求里**有没有 `tools` 参数**：

| 场景 | reasoning_content 是否回传 | 说明 |
|---|---|---|
| 请求**没有** `tools` | 不需要回传 | 即使传了也会被忽略，不进入上下文 |
| 请求**有** `tools` | **必须完整回传所有历史轮次** | 少传一条就返回 400 错误 |

这就是为什么"我只是加了个函数调用，怎么突然 400 了"——因为你用 `messages.append(...)` 时把 `reasoning_content` 丢了，或者手工拼 message 时只挑了 `content`。

### 正确做法：直接把整个 message 对象塞回列表

```python
messages.append(resp.choices[0].message)   # 不要手工复制字段！
```

SDK 返回的 message 对象里已经带好了 `reasoning_content`、`tool_calls`，原样追加即可。

### 错误做法（会 400）

```python
# ❌ 只保留 content，丢掉 reasoning_content
messages.append({"role": "assistant", "content": resp.choices[0].message.content})
```

### 多轮对话（不带 tools）

```python
messages = [{"role": "user", "content": "9.11 和 9.8 哪个大？"}]
resp = client.chat.completions.create(
    model="deepseek-flash", messages=messages,
    reasoning_effort="high",
    extra_body={"thinking": {"type": "enabled"}},
)
messages.append(resp.choices[0].message)      # 上一轮思维链会被 API 忽略
messages.append({"role": "user", "content": "那 strawberry 里有几个 r？"})
```

这种设计其实很合理：**不带工具时，上一轮的思维链对答案没有帮助，塞进上下文只是白烧 token**。官方直接帮你丢掉了。

## 四、思考模式 + 工具调用：完整循环

```python
import json, os
from openai import OpenAI

client = OpenAI(api_key=os.environ["DEEPSEEK_API_KEY"],
                base_url="https://api.deepseek.com")

tools = [{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "查询指定城市、指定日期的天气",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {"type": "string", "description": "城市名"},
                "date": {"type": "string", "description": "YYYY-mm-dd"},
            },
            "required": ["location", "date"],
        },
    },
}]

def get_weather(location: str, date: str) -> str:
    return f"{location} {date} 多云 7~13℃"

messages = [{"role": "user", "content": "杭州明天天气怎么样？"}]

while True:
    resp = client.chat.completions.create(
        model="deepseek-flash",
        messages=messages,
        tools=tools,
        reasoning_effort="high",
        extra_body={"thinking": {"type": "enabled"}},
    )
    msg = resp.choices[0].message
    messages.append(msg)           # ✅ 关键：整体追加，保住 reasoning_content

    if not msg.tool_calls:
        print(msg.content)
        break

    for call in msg.tool_calls:
        result = get_weather(**json.loads(call.function.arguments))
        messages.append({
            "role": "tool",
            "tool_call_id": call.id,
            "content": result,
        })
```

注意：**即使某一轮模型没有发起工具调用**，只要请求里带着 `tools`，这一轮的 `reasoning_content` 也必须回传。所以循环里不要做"没有 tool_calls 就 break 前先裁剪消息"这类优化。

## 五、几个容易误解的参数行为

**temperature / top_p 在思考模式下基本失效**

- `deepseek-flash`：思考模式下 `top_p` 只在 0.95~1.0 生效，低于 0.95 按 0.95 处理；非思考模式固定 1.0，传了也被忽略。
- `deepseek-v4-pro`：思考模式下 `top_p` 被忽略（带 tools 时固定 0.95，否则 1.0）；非思考模式才真正生效。
- `temperature`、`presence_penalty`、`frequency_penalty`：思考模式下设置不报错但无效果。

想控制输出稳定性，正确手段是：**非思考模式 + temperature=0 + 强约束 prompt**，而不是在思考模式下调 temperature。

**思维链不能"教"**

用思考模式的模型不需要 `Let's think step by step`、"请一步步推理"这类提示词，官方也明确不建议在 prompt 里塞入示例思维链。想影响推理方向，就写清楚任务约束、验收标准、可用工具。

**思维链可以展示但不要当真**

`reasoning_content` 适合折叠展示"模型在想什么"，但它不等于严格的推理证明，尤其是在 `low` 档下可能非常简略。不要把它当审计日志或决策依据。

## 六、成本提醒

思维链按输出 token 计费，输出单价是输入的 4~5 倍（以 `deepseek-flash` 谷时为例：输出 $0.6/1M，缓存未命中输入 $0.15/1M）。所以：

- 简单任务关思考，省的是最贵的那部分 token；
- 长任务用 `low`，多数场景质量损失可接受；
- 只有真正需要深推理时才上 `max`。

下一篇讲怎么靠上下文缓存和峰谷时段把账单再压一半。
