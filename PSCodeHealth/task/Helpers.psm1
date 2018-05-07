Function Get-TaskInputs {
    [CmdletBinding()]
    Param()

    [string]$Global:RootDirectoryPath = Get-VstsTaskVariable -Name 'Build.SourcesDirectory'
    Write-VstsTaskVerbose -Message "Value of RootDirectoryPath : $RootDirectoryPath"

    [string]$Global:SourceCodePath = Get-VstsInput -Name SourceCodePath -Default $RootDirectoryPath
    [string]$Global:TestsPath = Get-VstsInput -Name TestsPath -Default $RootDirectoryPath
    [bool]$Global:Recurse = Get-VstsInput -Name Recurse -AsBool
}

Function Write-TaskInputs {
    [CmdletBinding()]
    Param()

    Write-VstsTaskVerbose -Message "Value of RootDirectoryPath : $RootDirectoryPath"
    
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