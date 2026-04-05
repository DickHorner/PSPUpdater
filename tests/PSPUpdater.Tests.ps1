Import-Module (Join-Path $PSScriptRoot '..\PSPUpdater\PSPUpdater.psd1') -Force

Describe 'PSPUpdater private helpers' {
    It 'maps rc tags correctly' {
        $result = & (Get-Module PSPUpdater) { Get-PSPUReleaseStageFromTag -Tag 'v7.6.0-rc.1' }
        $result | Should Be 'rc'
    }

    It 'maps beta tags correctly' {
        $result = & (Get-Module PSPUpdater) { Get-PSPUReleaseStageFromTag -Tag 'v7.6.0-beta.4' }
        $result | Should Be 'beta'
    }

    It 'accepts stable as default selection' {
        $channels = @(
            [pscustomobject]@{ Key = 'stable'; DisplayName = 'Stable'; Version = '7.6.0'; ReleaseTag = 'v7.6.0'; Aliases = @('default') },
            [pscustomobject]@{ Key = 'daily'; DisplayName = 'Daily'; Version = '7.5.0-daily'; ReleaseTag = 'v7.5.0-daily'; Aliases = @() }
        )

        $selected = & (Get-Module PSPUpdater) { param($items) Resolve-PSPUSelection -Channels $items -Selection '' } $channels
        $selected.Key | Should Be 'stable'
    }
}
