[CmdletBinding()]
Param(
    [Parameter(Position=0, Mandatory=$False)]
    [ValidateScript({ Test-Path $_ })]
    [string]$SourceCodePath,
    
    [Parameter(Position=1, Mandatory=$False)]
    [ValidateScript({ Test-Path $_ })]
    [string]$TestsPath,

    [Parameter(Mandatory=$False)]
    [bool]$Recurse = $False
)

Write-Verbose "Loading PSCodeHealth module shipped in the VSTS extension"
Import-Module "$PSScriptRoot\ps_modules\0.2.9\PSCodeHealth.psd1" -Force

Write-Verbose "Loading PSScriptAnalyzer module shipped in the VSTS extension"
Import-Module "$PSScriptRoot\ps_modules\PSScriptAnalyzer\PSScriptAnalyzer.psd1" -Force

$PSVersionTable.PSVersion

Get-Module -Name 'Pester' -ListAvailable

Write-Host "Value of SourceCodePath : $SourceCodePath"
Write-Host "Value of TestsPath : $TestsPath"
Write-Host "Value of Recurse : $($Recurse)"
Write-Host "Type of Recurse : $($Recurse.GetType().FullName)"
