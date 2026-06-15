# ABU StudioOS

Universal project root for AbuZ8 studio orchestration.

## Purpose
- One shared root for Claude Code, Codex, Gemini CLI, OpenCode, and local router services
- One place to store job packets, templates, logs, and shared working memory
- Keep Claude-built OpenClaw memory intact while giving agents a clean collaboration surface

## Layout
- `memory/` shared notes, briefs, and rolling context
- `projects/` active project folders
- `packets/` generated production packets
- `agents/` agent-specific notes and outputs
- `logs/` run logs
- `templates/` reusable schemas and briefs
- `config/` shared registry and policies
- `docs/` architecture and operating docs

## Protected Systems
OpenClaw memory remains under `/home/user/.openclaw`. StudioOS references it but does not replace it.
