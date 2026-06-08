# PSPUpdater

`PSPUpdater` ist ein lokales PowerShell-Modul, das den Befehl `PSPU` bereitstellt.

`PSPU` holt die aktuell verfügbaren offiziellen PowerShell-Kanäle ab und startet auf Windows direkt die passende MSI-Installation. Standardauswahl ist `stable`, wenn du einfach nur Enter drueckst.

Aktuell unterstuetzte Kanaltypen:

- `stable`
- `lts`
- `daily`
- aktuelle Vorabkanäle wie `rc`, `beta`, `alpha` oder `preview`, falls sie offiziell verfügbar sind

## Installation

Im Repo-Ordner:

```powershell
.\Install-PSPUpdater.ps1
```

Danach kannst du direkt folgendes ausführen:

```powershell
PSPU
```

## Beispiele

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

## Technische Basis

Das Modul nutzt offizielle Quellen:

- `https://aka.ms/pwsh-buildinfo-stable`
- `https://aka.ms/pwsh-buildinfo-lts`
- `https://aka.ms/pwsh-buildinfo-daily`
- `https://api.github.com/repos/PowerShell/PowerShell/releases`

Damit kommt die Versionsauswahl direkt aus den offiziellen PowerShell-Releasefeeds statt aus hart codierten Downloadlinks.
