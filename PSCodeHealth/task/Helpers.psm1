Function Get-TaskInputs {
    [CmdletBinding()]
    Param()

    [string]$RootDirectoryPath = Get-VstsTaskVariable -Name 'Build.SourcesDirectory'

    [string]$SourceCodePath = Get-VstsInput -Name SourceCodePath -Default $RootDirectoryPath
    [string]$TestsPath = Get-VstsInput -Name TestsPath -Default $RootDirectoryPath
    [bool]$Recurse = Get-VstsInput -Name Recurse -AsBool
}

Function Write-TaskInputs {
    [CmdletBinding()]
    Param()

    Write-VstsTaskVerbose -Message "Value of SourceCodePath : $SourceCodePath"
    Write-VstsTaskVerbose -Message "Value of TestsPath : $TestsPath"
    Write-VstsTaskVerbose -Message "Value of Recurse : $($Recurse)"
}

Function Import-Dependencies {
    [CmdletBinding()]
    Param()

    Write-VstsTaskVerbose -Message "Loading PSScriptAnalyzer module shipped in the VSTS extension"
    Import-Module "$PSScriptRoot\ps_modules\PSScriptAnalyzer\PSScriptAnalyzer.psd1" -Force

    Write-VstsTaskVerbose -Message "Loading PSCodeHealth module shipped in the VSTS extension"
    Import-Module "$PSScriptRoot\ps_modules\PSCodeHealth\PSCodeHealth.psd1" -Force
}

Export-ModuleMember -Function '*'