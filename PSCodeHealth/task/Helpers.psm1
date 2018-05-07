Function Get-TaskInputs {
    [CmdletBinding()]
    Param()

    [string]$Global:RootDirectoryPath = Get-VstsTaskVariable -Name 'Build.SourcesDirectory'

    [string]$Global:SourceCodePath = Get-VstsInput -Name SourceCodePath -Default $RootDirectoryPath
    [string]$Global:TestsPath = Get-VstsInput -Name TestsPath -Default $RootDirectoryPath
    [bool]$Global:Recurse = Get-VstsInput -Name Recurse -AsBool
}

Function Write-TaskInputs {
    [CmdletBinding()]
    Param()

    "Value of RootDirectoryPath : $RootDirectoryPath"

    "Value of SourceCodePath : $SourceCodePath"
    "Value of TestsPath : $TestsPath"
    "Value of Recurse : $($Recurse)"
}

Function Import-Dependencies {
    [CmdletBinding()]
    Param()

    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    'Installing module [Pester] from the PowerShell Gallery ...'
    Install-Module 'Pester' -Scope CurrentUser -Force -SkipPublisherCheck
    Import-Module 'Pester'

    'Loading PSScriptAnalyzer module shipped in the VSTS extension'
    Import-Module "$PSScriptRoot\ps_modules\PSScriptAnalyzer\PSScriptAnalyzer.psd1" -Force

    'Loading PSCodeHealth module shipped in the VSTS extension'
    Import-Module "$PSScriptRoot\ps_modules\PSCodeHealth\PSCodeHealth.psd1" -Force
}

Export-ModuleMember -Function '*'