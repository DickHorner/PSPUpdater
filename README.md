# PSPUpdater

[English](README.md) | [Deutsch](README.de.md)

`PSPUpdater` is a local PowerShell module that provides the `PSPU` command.

`PSPU` retrieves the currently available official PowerShell channels and, on Windows, directly starts the matching MSI installation. The default selection is `stable` if you simply press Enter.

Currently supported channel types:

- `stable`
- `lts`
- `daily`
- current preview channels such as `rc`, `beta`, `alpha`, or `preview`, if they are officially available

## Installation

In the repository folder:

```powershell
.\Install-PSPUpdater.ps1
```

After that, you can run:

```powershell
PSPU
```

## Examples

Interactive selection:

```powershell
PSPU
```

List available channels only:

```powershell
PSPU -List
```

Install a channel directly:

```powershell
PSPU stable
PSPU rc
PSPU daily
```

Force reinstallation:

```powershell
PSPU stable -Force
```

## Technical basis

The module uses official sources:

- `https://aka.ms/pwsh-buildinfo-stable`
- `https://aka.ms/pwsh-buildinfo-lts`
- `https://aka.ms/pwsh-buildinfo-daily`
- `https://api.github.com/repos/PowerShell/PowerShell/releases`

This means the version selection comes directly from the official PowerShell release feeds instead of hard-coded download links.
