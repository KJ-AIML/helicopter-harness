# Install Helicopter-Harness Runtime

This directory is the runtime payload copied by the repository install scripts.

Prefer installing from the repository root:

```powershell
.\install.ps1 -Parent "D:\MyWorkspace"
```

```bash
./install.sh "$HOME/work/my-workspace"
```

The install scripts copy the contents of `.helicopter-harness/` into the parent-workspace harness location and create adapter pointer files only when they do not already exist.

Do not install globally by default. Do not enable hooks automatically.
