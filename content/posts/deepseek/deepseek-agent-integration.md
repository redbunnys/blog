---
title: "用 DeepSeek 驱动编码 Agent：Claude Code / Codex 接入与 Search API 实战"
date: 2026-10-24T21:30:00+08:00
tags: ["DeepSeek", "AI", "Agent"]
categories: ["AI"]
featured_image: "https://w.wallhaven.cc/full/d8/wallhaven-d85ewm.png"
description: "把 DeepSeek 配到 Claude Code、Codex 等 Agent 工具上，并用官方 Search / Fetch API 给 Agent 加联网能力"
comment : true
hidden: false
draft: false
---

前四篇讲的是"怎么调模型"，这一篇讲"怎么把模型塞进工作流"。DeepSeek 的 API 同时兼容 OpenAI 与 Anthropic 协议，所以主流的编码 Agent 基本都能直接接。

## 一、Claude Code：改 6 个环境变量

Claude Code 走 Anthropic 协议，所以只需要把 `ANTHROPIC_BASE_URL` 指到 `/anthropic`。

Linux / macOS：

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=<你的 DeepSeek API Key>
export ANTHROPIC_MODEL=deepseek-flash[1m]
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-flash[1m]
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-flash[1m]
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=786432
```

Windows（PowerShell）：

```powershell
$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="<你的 DeepSeek API Key>"
$env:ANTHROPIC_MODEL="deepseek-flash[1m]"
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-flash[1m]"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-flash[1m]"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-flash"
$env:CLAUDE_CODE_SUBAGENT_MODEL="deepseek-flash"
$env:CLAUDE_CODE_EFFORT_LEVEL="max"
$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="786432"
```

然后在项目目录里直接 `claude` 即可。

几个参数值得单独说：

| 变量 | 作用 | 建议 |
|---|---|---|
| `deepseek-flash[1m]` | `[1m]` 后缀启用 1M 上下文 | 仓库级任务建议开，小任务可以不开省 token |
| `CLAUDE_CODE_EFFORT_LEVEL` | 思考强度 | `max` 最强；日常改代码可以降到 `high` 省钱 |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | 自动压缩触发窗口 | 786432（约 768K）给 1M 上下文留余量 |
| `CLAUDE_CODE_SUBAGENT_MODEL` | 子 Agent 用的小模型 | 用 flash 就够，子任务通常简单 |

**模型名映射规则**（容易踩坑）：Claude Code / Claude Desktop 里以 `claude-opus` 开头的模型名会被映射到 `deepseek-v4-pro`（按 Pro 价格计费），`claude-haiku` / `claude-sonnet` 开头映射到 `deepseek-flash`。也就是说，如果你在客户端里切了个"Opus"，账单会按 Pro 走——想省钱就把默认模型明确设成 flash。

另外，Claude Code 里的 Web Search 是原生的：模型判断需要联网时会调用 DeepSeek 的搜索服务，搜索本身按 Search API 计费（见下文），并且检索结果还要额外消耗一次模型 token 做总结。

## 二、Codex：走 Responses API

Codex 用 OpenAI 的 Responses API，DeepSeek 已原生支持。官方提供了一键配置脚本（会先备份原配置，并校验 `config.toml` / `models.json` 语法）：

```powershell
# Windows
irm https://cdn.deepseek.com/api-docs/codex-deepseek-setup-en.ps1 | iex
```

```bash
# macOS / Linux
bash <(curl -fsSL https://cdn.deepseek.com/api-docs/codex-deepseek-setup-en.sh)
```

菜单里选 1 配 `deepseek-flash`（支持图片输入），选 2 配 `deepseek-v4-pro`，选 9 恢复原始配置。脚本做了三件事：

1. 备份 `~/.codex/config.toml` 到 `~/.codex/backup-deepseek/`；
2. 写 `~/.codex/models.json`，声明 DeepSeek 模型的上下文档位、支持的思考强度档位、工具调用格式等元数据；
3. 改 `~/.codex/config.toml`，新增 `[model_providers.deepseek]` 段，并在 `[desktop]` 写 `enabled-reasoning-efforts`，同时保留你原有的 MCP server、项目信任等设置。

如果你更想手写配置，模型元数据的关键字段是：

```json
{
  "slug": "deepseek-flash",
  "context_window": 1048576,
  "max_context_window": 1048576,
  "effective_context_window_percent": 95,
  "input_modalities": ["text", "image"],
  "default_reasoning_level": "high",
  "supported_reasoning_levels": [
    {"effort": "low",  "description": "Fast responses with lighter reasoning"},
    {"effort": "high", "description": "Extra high reasoning depth for complex problems"},
    {"effort": "max",  "description": "Maximum reasoning depth for the hardest problems"}
  ]
}
```

注意 `supported_reasoning_levels` 只有 low/high/max 三档，和前一篇讲的强度映射一致。

## 三、其他工具

- **OpenCode / OpenClaw / Qoder / CodeBuddy**：官方文档都有对应章节，基本都是"填 base_url + api_key + model 名"三件套。
- **DeepSeek Harness**：官方自家的 Agent 框架，用新版模型建议升级到 0.2.1-rc.1 及以上（V4.1-Flash-1017 对 Harness、CodeBuddy 等平台做过专项优化）。
- **自研 Agent**：直接按前两篇的 OpenAI 格式写，别忘 `reasoning_content` 回传规则。

## 四、Search / Fetch API：给 Agent 加联网能力

2026-10-17 起官方把自研搜索引擎开放成了 API，两个端点，纯 JSON，Bearer 鉴权：

| API | 端点 |
|---|---|
| Search | `POST https://api.deepseek.com/v1/tools/search` |
| Fetch | `POST https://api.deepseek.com/v1/tools/fetch` |

### Search 请求参数

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `query` | string | 是 | 1~128 字符，支持查询运算符 |
| `count` | int | 否 | 返回条数 1~50，默认 10 |
| `ori_question` | string | 否 | 用户原问题，帮助提升查询理解 |
| `localization` | string | 否 | 可选 IP，用于结果本地化 |
| `need_content` | bool | 否 | 是否返回正文，默认 false |

```python
import os, requests

r = requests.post(
    "https://api.deepseek.com/v1/tools/search",
    headers={"Authorization": f"Bearer {os.environ['DEEPSEEK_API_KEY']}"},
    json={"query": "DeepSeek V4 release notes", "count": 5, "need_content": True},
    timeout=30,
)
r.raise_for_status()
for item in r.json()["results"]:
    print(item["authority"], item["rerank_score"], item["title"], item["url"])
```

返回的每条结果都带几个很有用的质量信号：

- `rerank_score`：0~3 的相关性综合分，≥1.5 视为高质量；
- `authority`：0~4 的权威度分层，≥3 属于高权威来源；
- `summary`：600~800 字的摘要，**给模型读的**；`snippet` 只有 100~200 字，**给人看的**；
- `content`：`need_content=true` 时返回的正文。

给 Agent 用的时候，喂 `summary` 而不是 `snippet`，效果明显更好。

### 查询运算符

搜索语法会原样透传，常用的有：

| 运算符 | 示例 | 作用 |
|---|---|---|
| `site:` | `DeepSeek site:github.com` | 限定站点，多个用空格 + `OR` |
| `-site:` | `DeepSeek -site:example.com` | 排除站点 |
| `-词` / `-"短语"` | `DeepSeek -广告` | 排除词或短语 |
| `"..."` | `DeepSeek "exact phrase"` | 精确短语 |
| `lang:` | `DeepSeek lang:zh,en` | 限定语言 |
| `after:` / `before:` | `DeepSeek after:2025-01-01` | 时间范围 |

官方特别提到会过滤 SEO 垃圾、GEO 操纵和低质 AIGC 内容，所以比起自己接通用搜索 API，做个技术资料检索时噪声确实少一些。

### Fetch

```python
r = requests.post(
    "https://api.deepseek.com/v1/tools/fetch",
    headers={"Authorization": f"Bearer {os.environ['DEEPSEEK_API_KEY']}"},
    json={"url": "https://example.com/article"},
    timeout=60,
)
page = r.json()
print(page["title"])
print(page["content"][:500])   # Markdown 正文
```

URL 必须是 HTTP(S)、长度 ≤8192、不能带账号密码。抓取受目标站点策略限制，拿不到可用正文会返回 404。

### 计费与限流

| 项 | 值 |
|---|---|
| Search | $0.75 / 1000 次成功请求 |
| Fetch | $0.75 / 1000 次成功请求 |
| Search QPS | 100（账号级） |
| Fetch QPS | 25（账号级 + 域名级） |

计费规则：**只有返回 200 且有结果才收费**（Search 结果数组非空、Fetch 拿到正文）。`count` 大小不影响单价，所以一次多取几条更划算。

另外：通过 DeepSeek Harness / Claude Code / Codex 触发的服务端搜索，目前免费，但**从 2026-11-01 00:00（北京时间）起开始按请求计费**，跑长任务的要提前把这块钱算进去。

## 五、一个最小可用的检索型 Agent 循环

把前面的能力拼起来：模型决定要不要搜 → 调 Search API → 喂 summary → 出答案。

```python
import json, os, requests
from openai import OpenAI

client = OpenAI(api_key=os.environ["DEEPSEEK_API_KEY"],
                base_url="https://api.deepseek.com")
KEY = os.environ["DEEPSEEK_API_KEY"]

def deepseek_search(query: str, count: int = 5) -> list[dict]:
    r = requests.post(
        "https://api.deepseek.com/v1/tools/search",
        headers={"Authorization": f"Bearer {KEY}"},
        json={"query": query, "count": count},
        timeout=30,
    )
    r.raise_for_status()
    return [
        {"title": x["title"], "url": x["url"], "summary": x["summary"]}
        for x in r.json()["results"]
        if x["rerank_score"] >= 1.5
    ]

tools = [{
    "type": "function",
    "function": {
        "name": "deepseek_search",
        "description": "联网搜索，返回高质量网页摘要",
        "parameters": {
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"],
        },
    },
}]

messages = [{"role": "user", "content": "DeepSeek V4.1-Flash 相比 V4 有哪些提升？"}]

while True:
    resp = client.chat.completions.create(
        model="deepseek-flash",
        messages=messages,
        tools=tools,
        reasoning_effort="high",
        extra_body={"thinking": {"type": "enabled"}},
    )
    msg = resp.choices[0].message
    messages.append(msg)                     # 带 tools 时必须整体回传
    if not msg.tool_calls:
        print(msg.content)
        break
    for call in msg.tool_calls:
        args = json.loads(call.function.arguments)
        result = deepseek_search(args["query"])
        messages.append({
            "role": "tool",
            "tool_call_id": call.id,
            "content": json.dumps(result, ensure_ascii=False),
        })
```

## 六、接入时的几个经验

1. **先确认它是"真在跑 DeepSeek"**。很多工具会静默回退到默认厂商，接完跑一个"你是什么模型"的测试，再看 API 用量面板有没有扣费。
2. **思考强度别一路 max**。Agent 每次工具调用都走一遍 max，成本和延迟都会失控；日常 Agent 用 `high`，卡住了再切 `max`。
3. **上下文窗口给 Agent 留余量**。1M 是上限，不是目标；自动压缩阈值设到 768K 左右，比撑爆了再报错好。
4. **Search 结果做过滤**。`rerank_score < 1.5` 或 `authority == 0` 的结果直接丢，能显著减少幻觉引用。
5. **把成本埋点接上**。每条日志记录 `prompt_cache_hit_tokens`、`completion_tokens` 和搜索次数，不然月底对不上账。

到这里这个系列就完整了：入门选型 → API 调用 → 思考模式 → 成本优化 → Agent 落地。后面打算再补一篇本地部署（vLLM / SGLang 跑 V4-Flash 权重）的实操记录。
