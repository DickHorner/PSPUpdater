@{
    RootModule           = 'PSPUpdater.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'f1c8293f-0f3a-418d-b90e-7c6c64891a30'
    Author               = 'DickHorner'
    CompanyName          = 'DickHorner'
    Copyright            = '(c) 2026 DickHorner'
    Description          = 'Interactive updater for PowerShell and PowerShell preview channels.'
    PowerShellVersion    = '7.0'
    FunctionsToExport    = @('PSPU')
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags       = @('PowerShell', 'Update', 'Installer', 'Preview', 'Windows', 'MSI', 'Upgrade')
            ProjectUri = 'https://github.com/DickHorner/PSPUpdater'
            LicenseUri = 'https://github.com/DickHorner/PSPUpdater/blob/main/LICENSE'
        }
    }
}
