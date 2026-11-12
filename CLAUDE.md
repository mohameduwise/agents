# Project: claude-agents

Claude Code plugin marketplace — 75 focused plugins, 182 agents, 147 skills, 95 commands.

## Repository Structure

```
claude-agents/
├── .claude-plugin/marketplace.json   # Registry of all plugins
├── plugins/                          # All 72 plugins
│   ├── <plugin-name>/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/*.md
│   │   ├── commands/*.md
│   │   └── skills/<skill-name>/SKILL.md
│   └── ...
├── docs/                             # Documentation
│   ├── plugins.md                    # Plugin catalog
│   ├── agents.md                     # Agent reference
│   ├── agent-skills.md               # Skills reference
│   ├── usage.md                      # Usage guide
│   ├── architecture.md               # Design principles
│   └── plugin-eval.md                # Evaluation framework
└── tools/                            # Development utilities
```

## Plugin Authoring Conventions

### Agent frontmatter

```yaml
---
name: agent-name
description: "What this agent does. Use PROACTIVELY when [trigger conditions]."
model: opus|sonnet|haiku|inherit
color: blue|green|red|yellow|cyan|magenta # optional
tools: Read, Grep, Glob # optional — restricts available tools
---
```

### Skill structure

```
skills/<skill-name>/
├── SKILL.md              # Required — frontmatter + content
├── references/           # Optional — supporting material
│   └── *.md
└── assets/               # Optional — templates, configs
```

Skill frontmatter:

```yaml
---
name: skill-name
description: "Use this skill when [specific trigger conditions]."
---
```

### Command frontmatter

```yaml
---
description: What this command does
argument-hint: <path> [--flag]
---
```

### plugin.json

Only `name` is required. Agents, commands, and skills are auto-discovered from directory structure.

```json
{ "name": "plugin-name" }
```

### marketplace.json

Lists all plugin component paths for the registry. Agents as `./agents/name.md`, skills as `./skills/skill-name` (directory, not SKILL.md).

## Model Tiers

| Tier   | Model   | Use Case                                               |
| ------ | ------- | ------------------------------------------------------ |
| Tier 1 | Opus    | Architecture, security, code review, production coding |
| Tier 2 | Inherit | Complex tasks — user chooses model                     |
| Tier 3 | Sonnet  | Docs, testing, debugging, support                      |
| Tier 4 | Haiku   | Fast ops, SEO, deployment, simple tasks                |

## PluginEval — Quality Evaluation Framework

Three-layer evaluation system in `plugins/plugin-eval/`. Full docs: [docs/plugin-eval.md](docs/plugin-eval.md).

### Quick Reference

```bash
cd plugins/plugin-eval

# Run tests
uv run pytest

# Evaluate a skill (static only)
uv run plugin-eval score path/to/skill --depth quick --output json

# Evaluate with LLM judge
uv run plugin-eval score path/to/skill --depth standard

# Full certification (all 3 layers)
uv run plugin-eval certify path/to/skill

# Compare two skills
uv run plugin-eval compare path/to/skill-a path/to/skill-b

# Build corpus for Elo ranking
uv run plugin-eval init plugins/
```

### Evaluation Layers

1. **Static** (Layer 1) — Deterministic structural analysis. < 2 seconds, free, always runs.
2. **LLM Judge** (Layer 2) — Semantic evaluation via Claude (Haiku + Sonnet). ~30s, 4 LLM calls.
3. **Monte Carlo** (Layer 3) — Statistical reliability via N simulated runs. ~2–5 min, 50–100 calls.

### 10 Dimensions (weights)

triggering_accuracy (25%), orchestration_fitness (20%), output_quality (15%), scope_calibration (12%), progressive_disclosure (10%), token_efficiency (6%), robustness (5%), structural_completeness (3%), code_template_quality (2%), ecosystem_coherence (2%)

### Badges

Platinum ≥90, Gold ≥80, Silver ≥70, Bronze ≥60

### Anti-Patterns

OVER_CONSTRAINED (>15 MUST/ALWAYS/NEVER), EMPTY_DESCRIPTION (<20 chars), MISSING_TRIGGER (no "Use when…"), BLOATED_SKILL (>800 lines no refs), ORPHAN_REFERENCE (dead link), DEAD_CROSS_REF (missing skill)

### Tech Stack

- Python ≥ 3.12, uv, ruff, ty, pytest
- Dependencies: pydantic, typer, rich, pyyaml
- Optional: claude-agent-sdk (LLM layers), anthropic (API alternative)

## LangGraph Reference

A read-only clone of [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph) lives next to this repo at `../langchain-ai/langgraph` (also opened by `agents.code-workspace` in VS Code).

- **Before LangGraph work** (editing `plugins/llm-application-dev/` or writing LangGraph code), run `tools/sync-langgraph.sh` to clone or update it, then verify APIs against the source, not memory.
- **Never edit** the reference clone; it is reset on each sync.

### Verified facts (langgraph 1.2.21, synced 2026-11-12 — update this block when a sync shows a new version)

- `langgraph.prebuilt.create_react_agent` is **deprecated** → use `from langchain.agents import create_agent`.
- `MessageGraph` is deprecated (removal in 2.0) → `StateGraph` with a `messages` key / `MessagesState`.
- `langgraph.prebuilt` and supervisor/swarm packages are **maintenance-only**. LangGraph positions itself as the low-level runtime; new agent-building examples should use **Deep Agents** (`langchain-ai/deepagents`).
- Current primitives: `StateGraph`, `START`/`END`, `add_messages`, `Command`, `Send`, `interrupt()` (`langgraph.types`); functional API `@entrypoint` / `@task` (`langgraph.func`).
- `MemorySaver` is a back-compat alias → use `InMemorySaver`. `PostgresSaver.from_conn_string(...)` is a **context manager** (`with ... as cp: cp.setup()`).
- **langchain 1.5.0** (`langchain-ai/langchain`, `libs/langchain_v1`): `create_agent(model, tools=None, *, system_prompt, middleware, response_format, state_schema, context_schema, checkpointer, store, interrupt_before, interrupt_after, debug, name, cache, transformers)`. Middleware in `langchain.agents.middleware`: `HumanInTheLoopMiddleware(interrupt_on={...})`, `SummarizationMiddleware(model, trigger=("tokens"|"messages"|"fraction", n))`, `ModelRetryMiddleware`, `ToolCallLimitMiddleware`, `PIIMiddleware`, etc. HITL resume: `Command(resume={"decisions": [{"type": "approve"|"edit"|"reject"|"respond"}]})`. Legacy `Conversation*Memory` lives only in `langchain-classic`.
- To re-verify langchain: `git clone --depth 1 --filter=blob:none --sparse https://github.com/langchain-ai/langchain ../langchain-ai/langchain && git -C ../langchain-ai/langchain sparse-checkout set libs/langchain_v1`.

### Plugin content aligned with these facts

`plugins/llm-application-dev` v2.1.0: `skills/langchain-architecture`, `commands/langchain-agent.md`, `agents/ai-engineer.md`. When the facts above change, update those files and bump the version in `plugin.json` and `marketplace.json`.

### Where to look in the clone

| Need | Path |
| --- | --- |
| Repo conventions & direction | `AGENTS.md` |
| Graph API | `libs/langgraph/langgraph/graph/state.py` |
| `Command`, `Send`, `interrupt` | `libs/langgraph/langgraph/types.py` |
| Functional API | `libs/langgraph/langgraph/func/__init__.py` |
| Prebuilt (`ToolNode`, deprecations) | `libs/prebuilt/langgraph/prebuilt/` |
| Checkpointers | `libs/checkpoint*/` |
| Docs index | `docs/llms.txt` |
| Examples | `examples/` |
| Package versions | `libs/*/pyproject.toml` |

## Development

### Python Tooling

Use the Astral Rust toolchain: `uv` (package manager), `ruff` (linter/formatter), `ty` (type checker). Do not use pip, mypy, or black.

### Adding a Plugin

1. Create `plugins/<name>/` with `.claude-plugin/plugin.json`
2. Add agents in `agents/`, commands in `commands/`, skills in `skills/`
3. Update `.claude-plugin/marketplace.json`
4. Follow naming conventions: lowercase, hyphen-separated
