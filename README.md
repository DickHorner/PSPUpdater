# PSPUpdater

## English

`PSPUpdater` is a local PowerShell module that provides the `PSPU` command.

`PSPU` retrieves the currently available official PowerShell channels and, on Windows, directly starts the matching MSI installation. The default selection is `stable` if you simply press Enter.

Currently supported channel types:

- `stable`
- `lts`
- `daily`
- current preview channels such as `rc`, `beta`, `alpha`, or `preview`, if they are officially available

### Installation

In the repository folder:

```powershell
.\Install-PSPUpdater.ps1
```

After that, you can run:

```powershell
PSPU
```

### Examples

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

### Technical basis

The module uses official sources:

- `https://aka.ms/pwsh-buildinfo-stable`
- `https://aka.ms/pwsh-buildinfo-lts`
- `https://aka.ms/pwsh-buildinfo-daily`
- `https://api.github.com/repos/PowerShell/PowerShell/releases`

This means the version selection comes directly from the official PowerShell release feeds instead of hard-coded download links.

---

## Deutsch

`PSPUpdater` ist ein lokales PowerShell-Modul, das den Befehl `PSPU` bereitstellt.

`PSPU` holt die aktuell verfügbaren offiziellen PowerShell-Kanäle ab und startet auf Windows direkt die passende MSI-Installation. Standardauswahl ist `stable`, wenn Du einfach nur Enter drückst.

Aktuell unterstützte Kanaltypen:

- `stable`
- `lts`
- `daily`
- aktuelle Vorabkanäle wie `rc`, `beta`, `alpha` oder `preview`, falls sie offiziell verfügbar sind

### Installation

Im Repo-Ordner:

```powershell
.\Install-PSPUpdater.ps1
```

Danach kannst Du direkt folgendes ausführen:

```powershell
PSPU
```

### Beispiele

Interaktive Auswahl:

```powershell
PSPU
```

Verfügbare Kanäle nur auflisten:

```powershell
PSPU -List
```

Direkt einen Kanal installieren:

```powershell
PSPU stable
PSPU rc
PSPU daily
```

Neuinstallation erzwingen:

```powershell
PSPU stable -Force
```

### Technische Basis

Das Modul nutzt offizielle Quellen:

- `https://aka.ms/pwsh-buildinfo-stable`
- `https://aka.ms/pwsh-buildinfo-lts`
- `https://aka.ms/pwsh-buildinfo-daily`
- `https://api.github.com/repos/PowerShell/PowerShell/releases`

Damit kommt die Versionsauswahl direkt aus den offiziellen PowerShell-Releasefeeds statt aus hart codierten Downloadlinks.
