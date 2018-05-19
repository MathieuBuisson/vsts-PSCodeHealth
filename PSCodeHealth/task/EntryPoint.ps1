[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
    'Loading helpers into the current scope'
    . "$PSScriptRoot\Helpers.ps1"

    $PSCodeHealthParams = Get-PSCodeHealthParamsFromInputs
    Write-PSCodeHealthParamsFromInputs $PSCodeHealthParams
    [int]$ExcludeCount = ($PSCodeHealthParams.Exclude | Measure-Object).Count
    Write-VstsTaskVerbose -Message "Number of elements in 'Exclude' task input : $($ExcludeCount)"

    Import-Dependencies

    'Running the PowerShell code analysis ...'
    $HealthReport = Invoke-PSCodeHealth @PSCodeHealthParams
    'Overall report view :'
    $HealthReport
    'Per-function report view :'
    $HealthReport.FunctionHealthRecords | Format-Table

    $GateParams = Get-GateParamsFromInputs
    Write-PSCodeHealthParamsFromInputs $GateParams
    If ( $GateParams.ContainsKey('CustomSettingsPath') ) {
        $CustomRules = ConvertFrom-Json (Get-Content $GateParams.CustomSettingsPath -Raw) | Where-Object { $_ }
        'Custom compliance rules :'
        Foreach ( $CustomComplianceRule in $CustomRules.OverallMetrics ) {
            $CustomComplianceRuleString = $CustomComplianceRule | Out-String
            "$CustomComplianceRuleString"
        }
    }
    $Compliance = Test-PSCodeHealthCompliance -HealthReport $HealthReport @GateParams

    'Compliance of evaluated metrics :'
    $Compliance

}
Finally {
    Trace-VstsLeavingInvocation $MyInvocation
}