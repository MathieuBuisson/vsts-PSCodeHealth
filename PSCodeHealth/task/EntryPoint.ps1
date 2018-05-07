[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
    Import-Module "$PSScriptRoot\Helpers.psm1" -Force -Verbose
    Get-TaskInputs
    Write-TaskInputs
    Import-Dependencies
    
    $PSVersionTable.PSVersion
    
    Get-Module -Name 'Pester' -ListAvailable
}
Finally {
    Trace-VstsLeavingInvocation $MyInvocation
}