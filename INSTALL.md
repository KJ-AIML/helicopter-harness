# Install Helicopter-Harness

Use the install scripts from the repository root.

## Windows

```powershell
.\install.ps1 -Parent "D:\KJ\Axtra-Intelion"
```

Installs to:

```text
D:\KJ\Axtra-Intelion\.helicopter-harness
```

## macOS/Linux

```bash
./install.sh "$HOME/work/axtra-intelion"
```

Installs to:

```text
$HOME/work/axtra-intelion/.helicopter-harness
```

## Adapter Pointers

The installer creates `AGENTS.md` and `CLAUDE.md` pointer files only if they do not already exist. If either file exists, append the relevant snippet manually.

Codex:

```text
Read the Helicopter-Harness Codex adapter first.
```

Claude Code:

```text
Read the Helicopter-Harness Claude adapter first.
```

## Safety

The install scripts do not install global rules, delete repos, overwrite existing parent agent files, or enable hooks automatically.
