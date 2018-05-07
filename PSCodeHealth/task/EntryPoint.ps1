[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
    'Loading helpers into the current scope'
    . "$PSScriptRoot\Helpers.ps1"

    $PSCodeHealthParams = Get-PSCodeHealthParamsFromInputs
    Write-PSCodeHealthParamsFromInputs $PSCodeHealthParams
    Import-Dependencies

    'Running the PowerShell code analysis ...'
    $HealthReport = Invoke-PSCodeHealth @PSCodeHealthParams
    'Overall report view :'
    $HealthReport
    'Per-function report view :'
    $HealthReport.FunctionHealthRecords | Format-Table
}
Finally {
    Trace-VstsLeavingInvocation $MyInvocation
}