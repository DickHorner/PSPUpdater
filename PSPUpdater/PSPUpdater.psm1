Set-StrictMode -Version Latest

function Invoke-PSPURestMethod {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Uri
    )

    $headers = @{
        'User-Agent' = 'PSPUpdater'
        'Accept'     = 'application/vnd.github+json'
    }

    try {
        Invoke-RestMethod -Uri $Uri -Headers $headers -ErrorAction Stop
    } catch {
        throw "PSPUpdater konnte '$Uri' nicht abrufen. $($_.Exception.Message)"
    }
}

function Get-PSPUArchitecture {
    [CmdletBinding()]
    param()

    if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
        return 'arm64'
    }

    if ($env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') {
        return 'arm64'
    }

    switch ($env:PROCESSOR_ARCHITECTURE) {
        'AMD64' { return 'x64' }
        'x86' { return 'x86' }
        default {
            throw "Nicht unterstuetzte Architektur: $($env:PROCESSOR_ARCHITECTURE)"
        }
    }
}

function Get-PSPUReleaseStageFromTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Tag
    )

    switch -Regex ($Tag) {
        '-rc\.' { return 'rc' }
        '-beta\.' { return 'beta' }
        '-alpha\.' { return 'alpha' }
        '-preview\.' { return 'preview' }
        default { return 'prerelease' }
    }
}

function Get-PSPUInstalledVersions {
    [CmdletBinding()]
    param()

    $searchRoots = @(
        (Join-Path $env:ProgramFiles 'PowerShell'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\powershell'),
        (Join-Path $env:USERPROFILE 'scoop\apps\pwsh')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

    $installed = New-Object System.Collections.Generic.List[object]

    foreach ($root in $searchRoots) {
        $executables = Get-ChildItem -LiteralPath $root -Filter 'pwsh.exe' -Recurse -File -ErrorAction SilentlyContinue
        foreach ($exe in $executables) {
            try {
                $version = & $exe.FullName -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
                if (-not [string]::IsNullOrWhiteSpace($version)) {
                    $installed.Add([pscustomobject]@{
                            Version = $version.Trim()
                            Path    = $exe.FullName
                        })
                }
            } catch {
                continue
            }
        }
    }

    $installed |
        Sort-Object Version -Descending -Unique
}

function Get-PSPUInstalledMsiProducts {
    [CmdletBinding()]
    param()

    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    Get-ItemProperty -Path $regPaths -ErrorAction SilentlyContinue |
        Where-Object {
            $_.PSObject.Properties['DisplayName'] -and
            $_.DisplayName -match '^PowerShell \d' -and
            $_.PSObject.Properties['PSChildName'] -and
            $_.PSChildName -match '^\{'
        } |
        ForEach-Object {
            [pscustomobject]@{
                DisplayName = $_.DisplayName
                Version     = $_.DisplayVersion
                ProductCode = $_.PSChildName
            }
        } |
        Sort-Object Version -Descending
}

function New-PSPUChannel {

    param(
        [Parameter(Mandatory)]
        [string] $Key,

        [Parameter(Mandatory)]
        [string] $DisplayName,

        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [string] $ReleaseTag,

        [Parameter(Mandatory)]
        [string] $DownloadUrl,

        [Parameter(Mandatory)]
        [string] $PackageName,

        [Parameter(Mandatory)]
        [string] $Description,

        [string[]] $Aliases = @(),

        [string] $ReleaseDate = ''
    )

    [pscustomobject]@{
        Key         = $Key
        DisplayName = $DisplayName
        Version     = $Version
        ReleaseDate = $ReleaseDate
        ReleaseTag  = $ReleaseTag
        DownloadUrl = $DownloadUrl
        PackageName = $PackageName
        Description = $Description
        Aliases     = $Aliases
    }
}

function Get-PSPUChannels {
    [CmdletBinding()]
    param()

    $architecture = Get-PSPUArchitecture
    $channels = New-Object System.Collections.Generic.List[object]

    # Fetch GitHub releases first so stable/LTS can look up their publish dates
    # from the same payload rather than making extra API calls.
    $githubReleases = Invoke-PSPURestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases?per_page=20'
    $releaseDateLookup = @{}
    foreach ($r in $githubReleases) {
        if ($r.published_at) {
            $releaseDateLookup[$r.tag_name] = ([datetime]$r.published_at).ToString('yyyy-MM-dd')
        }
    }

    $stableMeta = Invoke-PSPURestMethod -Uri 'https://aka.ms/pwsh-buildinfo-stable'
    $stableVersion = $stableMeta.ReleaseTag.TrimStart('v')
    $stablePackage = "PowerShell-$stableVersion-win-$architecture.msi"
    $stableDate = if ($releaseDateLookup.ContainsKey($stableMeta.ReleaseTag)) { $releaseDateLookup[$stableMeta.ReleaseTag] } else { '' }
    $channels.Add((New-PSPUChannel `
                -Key 'stable' `
                -DisplayName 'Stable' `
                -Version $stableVersion `
                -ReleaseDate $stableDate `
                -ReleaseTag $stableMeta.ReleaseTag `
                -DownloadUrl "https://github.com/PowerShell/PowerShell/releases/download/$($stableMeta.ReleaseTag)/$stablePackage" `
                -PackageName $stablePackage `
                -Description 'Neueste stabile PowerShell-Version' `
                -Aliases @('default')))

    $ltsMeta = Invoke-PSPURestMethod -Uri 'https://aka.ms/pwsh-buildinfo-lts'
    $ltsVersion = $ltsMeta.ReleaseTag.TrimStart('v')
    if ($ltsVersion -ne $stableVersion) {
        $ltsPackage = "PowerShell-$ltsVersion-win-$architecture.msi"
        $ltsDate = if ($releaseDateLookup.ContainsKey($ltsMeta.ReleaseTag)) { $releaseDateLookup[$ltsMeta.ReleaseTag] } else { '' }
        $channels.Add((New-PSPUChannel `
                    -Key 'lts' `
                    -DisplayName 'LTS' `
                    -Version $ltsVersion `
                    -ReleaseDate $ltsDate `
                    -ReleaseTag $ltsMeta.ReleaseTag `
                    -DownloadUrl "https://github.com/PowerShell/PowerShell/releases/download/$($ltsMeta.ReleaseTag)/$ltsPackage" `
                    -PackageName $ltsPackage `
                    -Description 'Aktuelle Long Term Support Version'))
    }

    $latestPrerelease = $null
    $addedStages = @{}

    foreach ($release in $githubReleases) {
        if (-not $release.prerelease -or $release.draft) {
            continue
        }

        $version = $release.tag_name.TrimStart('v')
        $assetName = "PowerShell-$version-win-$architecture.msi"
        $asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1

        if (-not $asset) {
            continue
        }

        $stage = Get-PSPUReleaseStageFromTag -Tag $release.tag_name
        if (-not $latestPrerelease) {
            $latestPrerelease = $stage
        }

        if ($addedStages.ContainsKey($stage)) {
            continue
        }

        $description = switch ($stage) {
            'rc' { 'Aktueller Release Candidate' }
            'beta' { 'Aktuelle Beta' }
            'alpha' { 'Aktuelle Alpha' }
            'preview' { 'Aktuelle Preview' }
            default { 'Aktuelle Vorabversion' }
        }

        $displayName = switch ($stage) {
            'rc' { 'RC' }
            'lts' { 'LTS' }
            default { $stage.Substring(0, 1).ToUpperInvariant() + $stage.Substring(1) }
        }

        $releaseDate = if ($release.published_at) { ([datetime]$release.published_at).ToString('yyyy-MM-dd') } else { '' }

        $channels.Add((New-PSPUChannel `
                    -Key $stage `
                    -DisplayName $displayName `
                    -Version $version `
                    -ReleaseDate $releaseDate `
                    -ReleaseTag $release.tag_name `
                    -DownloadUrl $asset.browser_download_url `
                    -PackageName $asset.name `
                    -Description $description `
                    -Aliases @()))

        $addedStages[$stage] = $true
    }

    $hasExplicitPreviewChannel = $channels.Key -contains 'preview'
    if ($latestPrerelease) {
        $latestChannel = $channels | Where-Object { $_.Key -eq $latestPrerelease } | Select-Object -First 1
        if ($latestChannel) {
            $aliases = @('prerelease')
            if (-not $hasExplicitPreviewChannel) {
                $aliases += 'preview'
            }

            $latestChannel.Aliases = $aliases
        }
    }

    $dailyMeta = Invoke-PSPURestMethod -Uri 'https://aka.ms/pwsh-buildinfo-daily'
    $dailyVersion = $dailyMeta.ReleaseTag.TrimStart('v')
    $dailyDate = if ($dailyMeta.ReleaseTag -match 'daily(\d{4})(\d{2})(\d{2})') {
        "$($Matches[1])-$($Matches[2])-$($Matches[3])"
    } else { '' }
    if ($architecture -eq 'x64') {
        $dailyPackage = "PowerShell-$dailyVersion-win-$architecture.msi"
        $channels.Add((New-PSPUChannel `
                    -Key 'daily' `
                    -DisplayName 'Daily' `
                    -Version $dailyVersion `
                    -ReleaseDate $dailyDate `
                    -ReleaseTag $dailyMeta.ReleaseTag `
                    -DownloadUrl "$($dailyMeta.BaseUrl)/$($dailyMeta.ReleaseTag)/$dailyPackage" `
                    -PackageName $dailyPackage `
                    -Description 'Letzter taeglicher Build'))
    }

    $preferredOrder = @{
        stable = 0
        lts = 1
        rc = 2
        beta = 3
        alpha = 4
        preview = 5
        prerelease = 6
        daily = 7
    }

    $channels |
        Sort-Object {
            if ($preferredOrder.ContainsKey($_.Key)) {
                $preferredOrder[$_.Key]
            } else {
                99
            }
        }
}

function Resolve-PSPUSelection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]] $Channels,

        [AllowEmptyString()]
        [string] $Selection
    )

    $selectedValue = if ([string]::IsNullOrWhiteSpace($Selection)) { 'stable' } else { $Selection.Trim() }

    if ($selectedValue -match '^\d+$') {
        $index = [int] $selectedValue
        if ($index -lt 1 -or $index -gt $Channels.Count) {
            throw "Ungueltige Auswahl '$selectedValue'."
        }

        return $Channels[$index - 1]
    }

    foreach ($channel in $Channels) {
        $names = @($channel.Key, $channel.DisplayName, $channel.Version, $channel.ReleaseTag) + $channel.Aliases
        if ($names | Where-Object { $_ -and $_.Equals($selectedValue, [System.StringComparison]::OrdinalIgnoreCase) }) {
            return $channel
        }
    }

    throw "Kanal '$selectedValue' wurde nicht gefunden."
}

function Show-PSPUSelectionMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]] $Channels,

        [object[]] $InstalledVersions = @()
    )

    Write-Host ''
    Write-Host 'Verfuegbare PowerShell-Kanaele:' -ForegroundColor Cyan

    for ($i = 0; $i -lt $Channels.Count; $i++) {
        $channel = $Channels[$i]
        $defaultMarker = if ($channel.Key -eq 'stable') { ' (default)' } else { '' }
        Write-Host ("[{0}] {1,-8} {2,-24} {3,-12} {4}{5}" -f ($i + 1), $channel.Key, $channel.Version, $channel.ReleaseDate, $channel.Description, $defaultMarker)
    }

    if ($InstalledVersions.Count -gt 0) {
        Write-Host ''
        Write-Host 'Gefundene lokale pwsh-Installationen:' -ForegroundColor DarkCyan
        foreach ($installed in $InstalledVersions) {
            Write-Host ("- {0}  {1}" -f $installed.Version, $installed.Path)
        }
    }

    Write-Host ''
    $selection = Read-Host 'Auswahl per Nummer oder Kanalname [stable]'
    Resolve-PSPUSelection -Channels $Channels -Selection $selection
}

function Test-PSPUVersionInstalled {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [object[]] $InstalledVersions
    )

    $InstalledVersions.Version -contains $Version
}

function Test-PSPUIsAdministrator {
    [CmdletBinding()]
    param()

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-PSPUChannel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object] $Channel
    )

    $downloadRoot = Join-Path $env:TEMP 'PSPUpdater'
    $downloadPath = Join-Path $downloadRoot $Channel.PackageName

    if (-not (Test-Path -LiteralPath $downloadRoot)) {
        $null = New-Item -Path $downloadRoot -ItemType Directory -Force
    }

    Write-Host ''
    Write-Host "Lade $($Channel.DisplayName) $($Channel.Version) herunter..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Channel.DownloadUrl -OutFile $downloadPath -ErrorAction Stop

    Write-Host "Starte Installation fuer $($Channel.Version)..." -ForegroundColor Cyan

    if (Test-PSPUIsAdministrator) {
        $process = Start-Process 'msiexec.exe' `
            -ArgumentList @('/i', "`"$downloadPath`"", '/passive', '/norestart') `
            -Wait -PassThru
    } else {
        # Start-Process -Verb RunAs on msiexec.exe (requireAdministrator manifest) routes
        # through the AppInfo UAC broker — the returned handle is the broker, not msiexec,
        # so -Wait exits immediately and ExitCode is meaningless.
        # Wrapping in an elevated pwsh (asInvoker manifest + explicit RunAs) gives a direct,
        # reliable process handle; the pwsh wrapper runs msiexec and forwards its exit code.
        $psExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
        $msiCmd = "msiexec.exe /i `"$downloadPath`" /passive /norestart; exit `$LASTEXITCODE"
        $process = Start-Process $psExe `
            -Verb RunAs `
            -ArgumentList @('-NoLogo', '-NoProfile', '-NonInteractive', '-Command', $msiCmd) `
            -WindowStyle Hidden `
            -Wait -PassThru
    }

    switch ($process.ExitCode) {
        0    { Write-Host "Installation erfolgreich: $($Channel.DisplayName) $($Channel.Version)" -ForegroundColor Green }
        1602 { Write-Warning "Installation abgebrochen." }
        3010 { Write-Warning "Installation abgeschlossen. Ein Neustart wird empfohlen." }
        default { throw "Die MSI-Installation ist mit ExitCode $($process.ExitCode) fehlgeschlagen." }
    }

    [pscustomobject]@{
        Channel    = $Channel.Key
        Version    = $Channel.Version
        Downloaded = $downloadPath
        ExitCode   = $process.ExitCode
    }
}

function Invoke-PSPUMsiUninstall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ProductCode,

        [string] $DisplayName = $ProductCode
    )

    Write-Host "Deinstalliere $DisplayName..." -ForegroundColor Cyan

    if (Test-PSPUIsAdministrator) {
        $process = Start-Process 'msiexec.exe' `
            -ArgumentList @('/x', $ProductCode, '/passive', '/norestart') `
            -Wait -PassThru
    } else {
        $psExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
        $msiCmd = "msiexec.exe /x $ProductCode /passive /norestart; exit `$LASTEXITCODE"
        $process = Start-Process $psExe `
            -Verb RunAs `
            -ArgumentList @('-NoLogo', '-NoProfile', '-NonInteractive', '-Command', $msiCmd) `
            -WindowStyle Hidden `
            -Wait -PassThru
    }

    switch ($process.ExitCode) {
        0    { Write-Host "Deinstalliert: $DisplayName" -ForegroundColor Green }
        3010 { Write-Warning "Deinstalliert. Ein Neustart wird empfohlen." }
        default { Write-Warning "Deinstallation fehlgeschlagen (ExitCode $($process.ExitCode))." }
    }
}

function Remove-PSPUOldVersions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $JustInstalledLabel
    )

    $products = @(Get-PSPUInstalledMsiProducts)
    if ($products.Count -le 1) {
        return
    }

    Write-Host ''
    Write-Host "Weitere installierte PowerShell-Versionen (soeben installiert: $JustInstalledLabel):" -ForegroundColor Cyan
    for ($i = 0; $i -lt $products.Count; $i++) {
        Write-Host ("[{0}] {1,-36} {2}" -f ($i + 1), $products[$i].DisplayName, $products[$i].Version)
    }

    Write-Host ''
    $selection = Read-Host 'Welche Versionen deinstallieren? (Nummern kommagetrennt, Enter zum Ueberspringen)'
    if ([string]::IsNullOrWhiteSpace($selection)) {
        return
    }

    foreach ($part in ($selection -split ',' | ForEach-Object { $_.Trim() })) {
        if ($part -notmatch '^\d+$') { continue }
        $idx = [int] $part
        if ($idx -lt 1 -or $idx -gt $products.Count) {
            Write-Warning "Ungueltige Auswahl: $idx"
            continue
        }
        $p = $products[$idx - 1]
        Invoke-PSPUMsiUninstall -ProductCode $p.ProductCode -DisplayName $p.DisplayName
    }
}

function PSPU {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string] $Channel,

        [switch] $List,

        [switch] $Force
    )

    $channels = @(Get-PSPUChannels)
    $installed = @(Get-PSPUInstalledVersions)

    if ($List) {
        for ($i = 0; $i -lt $channels.Count; $i++) {
            $channels[$i] | Add-Member -NotePropertyName Index -NotePropertyValue ($i + 1) -Force
        }

        return $channels
    }

    $selected = if ($PSBoundParameters.ContainsKey('Channel')) {
        Resolve-PSPUSelection -Channels $channels -Selection $Channel
    } else {
        Show-PSPUSelectionMenu -Channels $channels -InstalledVersions $installed
    }

    if ((-not $Force) -and (Test-PSPUVersionInstalled -Version $selected.Version -InstalledVersions $installed)) {
        Write-Host ''
        Write-Host "Version $($selected.Version) ist bereits installiert. Mit -Force kannst du trotzdem neu installieren." -ForegroundColor Yellow
        return
    }

    $installResult = Install-PSPUChannel -Channel $selected
    if ($installResult.ExitCode -in @(0, 3010)) {
        Remove-PSPUOldVersions -JustInstalledLabel "$($selected.DisplayName) $($selected.Version)"
    }
}

Export-ModuleMember -Function PSPU
