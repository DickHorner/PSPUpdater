# PSPUpdater

`PSPUpdater` ist ein lokales PowerShell-Modul, das den Befehl `PSPU` bereitstellt.

`PSPU` holt die aktuell verfuegbaren offiziellen PowerShell-Kanaele ab und startet auf Windows direkt die passende MSI-Installation. Standardauswahl ist `stable`, wenn du einfach nur Enter drueckst.

Aktuell unterstuetzte Kanaltypen:

- `stable`
- `lts`
- `daily`
- aktuelle Vorabkanaele wie `rc`, `beta`, `alpha` oder `preview`, falls sie offiziell verfuegbar sind

## Installation

Im Repo-Ordner:

```powershell
.\Install-PSPUpdater.ps1
```

Danach kannst du direkt folgendes ausfuehren:

```powershell
PSPU
```

## Beispiele

Interaktive Auswahl:

```powershell
PSPU
```

Verfuegbare Kanaele nur auflisten:

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
