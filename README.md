# PSPUpdater

<details open>
<summary>🇬🇧 English</summary>

`PSPUpdater` is a local PowerShell module that adds the `PSPU` command.

It checks the official PowerShell release feeds, shows the currently available channels and installs the selected Windows MSI package. If you start `PSPU` without arguments, it opens an interactive selection menu. Pressing Enter selects `stable`.

## What it does

- detects the local processor architecture (`x64`, `x86` or `arm64`)
- reads the current PowerShell release information from official Microsoft and GitHub sources
- supports stable, LTS, daily and currently available preview channels
- downloads the matching Windows MSI package
- starts the MSI installer directly
- shows locally installed `pwsh.exe` versions before installation
- offers to remove older MSI-based PowerShell installations after a successful update

## Supported channels

`PSPU` can install the following channel types when they are officially available:

- `stable`
- `lts`
- `daily`
- preview channels such as `rc`, `beta`, `alpha` or `preview`

Preview channels are detected dynamically from the official PowerShell releases. The `preview` and `prerelease` aliases point to the latest available preview stage when applicable.

## Requirements

- Windows
- PowerShell 7.0 or newer
- internet access
- permission to run MSI installations

If the shell is not already elevated, `PSPUpdater` starts the MSI installation through a UAC prompt.

## Installation

In the repository folder:

```powershell
.\Install-PSPUpdater.ps1
```

After that, you can run:

```powershell
PSPU
```

If the module is already installed and you want to replace it, run:

```powershell
.\Install-PSPUpdater.ps1 -Force
```

## Usage

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

Force reinstallation of an already installed version:

```powershell
PSPU stable -Force
```

## Technical basis

The module uses official sources:

- `https://aka.ms/pwsh-buildinfo-stable`
- `https://aka.ms/pwsh-buildinfo-lts`
- `https://aka.ms/pwsh-buildinfo-daily`
- `https://api.github.com/repos/PowerShell/PowerShell/releases`

Version selection comes from the official PowerShell release feeds. Download URLs are built from the release metadata instead of being hard-coded.

</details>

<details>
<summary>🇩🇪 Deutsch</summary>

`PSPUpdater` ist ein lokales PowerShell-Modul, das den Befehl `PSPU` bereitstellt.

Das Modul liest die offiziellen PowerShell-Releasefeeds aus, zeigt die aktuell verfügbaren Kanäle an und installiert das passende Windows-MSI-Paket. Wenn Du `PSPU` ohne Argumente startest, öffnet sich eine interaktive Auswahl. Mit Enter wird `stable` ausgewählt.

## Was das Modul macht

- erkennt die lokale Prozessorarchitektur (`x64`, `x86` oder `arm64`)
- liest aktuelle PowerShell-Releaseinformationen aus offiziellen Microsoft- und GitHub-Quellen
- unterstützt Stable, LTS, Daily und aktuell verfügbare Preview-Kanäle
- lädt das passende Windows-MSI-Paket herunter
- startet die MSI-Installation direkt
- zeigt vor der Installation lokal gefundene `pwsh.exe`-Versionen an
- bietet nach einem erfolgreichen Update an, ältere MSI-basierte PowerShell-Installationen zu entfernen

## Unterstützte Kanäle

`PSPU` kann folgende Kanaltypen installieren, sofern sie offiziell verfügbar sind:

- `stable`
- `lts`
- `daily`
- Preview-Kanäle wie `rc`, `beta`, `alpha` oder `preview`

Preview-Kanäle werden dynamisch aus den offiziellen PowerShell-Releases erkannt. Die Aliasse `preview` und `prerelease` verweisen bei Bedarf auf die neueste verfügbare Preview-Stufe.

## Voraussetzungen

- Windows
- PowerShell 7.0 oder neuer
- Internetzugang
- Berechtigung zum Ausführen von MSI-Installationen

Wenn die Shell nicht bereits mit Administratorrechten läuft, startet `PSPUpdater` die MSI-Installation über eine UAC-Abfrage.

## Installation

Im Repository-Ordner:

```powershell
.\Install-PSPUpdater.ps1
```

Danach kannst Du ausführen:

```powershell
PSPU
```

Wenn das Modul bereits installiert ist und ersetzt werden soll, verwende:

```powershell
.\Install-PSPUpdater.ps1 -Force
```

## Verwendung

Interaktive Auswahl:

```powershell
PSPU
```

Verfügbare Kanäle nur auflisten:

```powershell
PSPU -List
```

Einen Kanal direkt installieren:

```powershell
PSPU stable
PSPU rc
PSPU daily
```

Neuinstallation einer bereits installierten Version erzwingen:

```powershell
PSPU stable -Force
```

## Technische Basis

Das Modul nutzt offizielle Quellen:

- `https://aka.ms/pwsh-buildinfo-stable`
- `https://aka.ms/pwsh-buildinfo-lts`
- `https://aka.ms/pwsh-buildinfo-daily`
- `https://api.github.com/repos/PowerShell/PowerShell/releases`

Die Versionsauswahl kommt aus den offiziellen PowerShell-Releasefeeds. Download-URLs werden aus den Release-Metadaten gebildet, statt fest im Code hinterlegt zu sein.

</details>
