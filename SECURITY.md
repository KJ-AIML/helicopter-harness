# Security Policy

## Install Scripts

Inspect `install.ps1`, `install.sh`, `update.ps1`, `update.sh`, `uninstall.ps1`, and `uninstall.sh` before running them. They are intended to copy harness files and manage only the harness install directory.

## Hooks

Hooks are optional. No destructive hook should be enabled without explicit user review and consent.

The bundled hook is a context-injection example. It should not edit files, run repo commands, deploy, delete, or block commands.

## Reporting Security Issues

Report security issues through GitHub issues or contact the maintainer privately when a private disclosure channel is added.

Placeholder private contact: `security@example.invalid`

