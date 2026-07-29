# Useful Skills

A small collection of reusable Codex skills for personal workflows.

## Layout

Each skill has one canonical directory:

```text
<category>/<skill-id>/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/        # optional, loaded only when needed
└── scripts/           # optional, deterministic helpers
```

`<skill-id>` uses lowercase kebab-case. `SKILL.md` is the required operational
contract; resources are added only when they remove repeated work or hold
task-specific reference material.

## General

| Skill | Canonical directory | Purpose |
|---|---|---|
| User Attention Alert | `general/user-attention-alert` | Notify the user only when a verified gate needs immediate action. |
| PowerShell Windows Reliability | `general/powershell-windows-reliability` | Run and diagnose Windows PowerShell, Unicode-path, native-CLI, and approval-bound commands reliably. |

## Use

Keep the category and skill directory intact when installing a skill into the
local Codex skills directory. Invoke a skill explicitly as `$<skill-id>`, or
allow Codex to select it when its description matches the task.
