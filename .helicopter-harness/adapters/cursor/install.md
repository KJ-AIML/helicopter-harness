# Cursor Install

From the parent workspace:

```powershell
Set-Content -Path .\.cursorrules -Value "Read .helicopter-harness/adapters/cursor/CURSOR.md first."
```

Or for scoped rules, create `.cursor/rules/harness.mdc`:

```markdown
---
description: Helicopter-Harness operating protocol
globs:
alwaysApply: true
---

Read .helicopter-harness/adapters/cursor/CURSOR.md first.
```

Do not copy Helicopter-Harness into Cursor's global settings by default. This harness is intended to live with the parent workspace.
