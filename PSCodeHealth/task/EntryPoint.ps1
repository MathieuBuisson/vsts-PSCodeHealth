[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
    Import-Module "$PSScriptRoot\Helpers.psm1" -Force -Verbose
    Get-TaskInputs
    Write-TaskInputs -Verbose
    Import-Dependencies
    
    $PSVersionTable.PSVersion
    
    Get-Module -Name 'Pester' -ListAvailable
    Get-Module -Name 'PackageManagement' -ListAvailable

    '------------------------------- Variables --------------------------------'
    Get-VstsTaskVariableInfo
}
Finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
