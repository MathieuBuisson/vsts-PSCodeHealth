Function Test-CustomSettingsJson {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [string]$Path
    )

    Try {
        $CustomSettings = ConvertFrom-Json (Get-Content -Path $Path -Raw) -ErrorAction Stop | Where-Object { $_ }
    }
    Catch {
        Throw "An error occurred when attempting to parse JSON data from the file $Path. Please verify that the content of this file is in valid JSON format."
    }

    $MetricsGroupNames = @('PerFunctionMetrics', 'OverallMetrics')
    $MetricsGroupNamesFromFile = ($CustomSettings | Get-Member -MemberType Properties).Name
    Foreach ( $MetricsGroupName in $MetricsGroupNames ) {
        If ( $MetricsGroupName -notin $MetricsGroupNamesFromFile ) {
            Throw "The metrics group $MetricsGroupName is missing from the JSON content of $Path."
        }
    }

    $MetricsRules = $CustomSettings.OverallMetrics
    $MetricNames = @('LinesOfCodeTotal', 'LinesOfCodeAverage', 'ScriptAnalyzerFindingsTotal', 'ScriptAnalyzerErrors', 'ScriptAnalyzerWarnings', 'ScriptAnalyzerInformation', 'ScriptAnalyzerFindingsAverage', 'NumberOfFailedTests', 'TestsPassRate', 'TestCoverage', 'CommandsMissedTotal', 'ComplexityAverage', 'ComplexityHighest', 'NestingDepthAverage', 'NestingDepthHighest')
    Foreach ( $MetricsRule in $MetricsRules ) {
        $MetricName = ($MetricsRule | Get-Member -MemberType NoteProperty).Name
        Write-VstsTaskVerbose -Message "Validating custom rule for metric : [$MetricName]."
        If ( $MetricName -notin $MetricNames ) {
            Throw "The custom rule [$MetricName] does not match a valid metric name in PSCodeHealth."
        }
    }
}

Function Get-PSCodeHealthParamsFromInputs {
    [CmdletBinding()]
    Param()

    [string]$RootDirectoryPath = Get-VstsTaskVariable -Name 'Build.SourcesDirectory'
    [string]$StagingDirectory = Get-VstsTaskVariable -Name 'Build.ArtifactStagingDirectory'

    $InputsHashTable = @{
        Path         = Get-VstsInput -Name SourceCodePath -Default $RootDirectoryPath
        TestsPath    = Get-VstsInput -Name TestsPath -Default $RootDirectoryPath
        Recurse      = Get-VstsInput -Name Recurse -AsBool
    }

    If ( Get-VstsInput -Name GenerateHtmlReport -AsBool ) {
        $HtmlReportPath = Get-VstsInput -Name HtmlReportPath -Default "$StagingDirectory\PSCodeHealth.html"
        $InputsHashTable.Add('HtmlReportPath', $HtmlReportPath)

        # To output both an HTML file and a [PSCodeHealth.Overall.HealthReport] object
        $InputsHashTable.Add('PassThru', $True)

        $CustomSettingsPath = Get-VstsInput -Name 'CustomSettingsPath'
        If ( $CustomSettingsPath -and ($CustomSettingsPath -match '\\\S+\.json$') ) {
            Test-CustomSettingsJson -Path $CustomSettingsPath -ErrorAction Stop
            $InputsHashTable.Add('CustomSettingsPath', $CustomSettingsPath)
        }
    }

    If ( Get-VstsInput -Name Exclude -Default $False ) {
        $Exclude = (Get-VstsInput -Name Exclude) -split '\n' | ForEach-Object { $_.Trim() }
        $InputsHashTable.Add('Exclude', $Exclude)
    }

    return $InputsHashTable
}

Function Write-PSCodeHealthParamsFromInputs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [Hashtable]$InputsHashTable
    )

    If ( -not($InputsHashTable) ) {
        return
    }
    Foreach ( $InputEntry in $InputsHashTable.GetEnumerator() ) {
        "Value of [$($InputEntry.Key)] : $($InputEntry.Value)"
    }
}

Function Import-Dependencies {
    [CmdletBinding()]
    Param()

    $IsPesterInstalled = Get-Module -Name 'Pester' -ListAvailable
    If ( $IsPesterInstalled ) {
        'The module [Pester] is already present, skipping installation.'
    }
    Else {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        'Installing module [Pester] from the PowerShell Gallery ...'
        Install-Module 'Pester' -Scope CurrentUser -Force -SkipPublisherCheck
    }
    'Loading module [Pester]'
    Import-Module 'Pester' -Force

    'Loading module [PSScriptAnalyzer] shipped in the VSTS extension'
    Import-Module "$PSScriptRoot\ps_modules\PSScriptAnalyzer\PSScriptAnalyzer.psd1" -Force

    'Loading module [PSCodeHealth] shipped in the VSTS extension'
    Import-Module "$PSScriptRoot\ps_modules\PSCodeHealth\PSCodeHealth.psd1" -Force
}

Function Get-MetricNamesFromInputs {
    [CmdletBinding()]
    Param()

    $MetricsInputNames = @('LinesOfCodeAverage', 'ScriptAnalyzerFindingsTotal', 'ScriptAnalyzerErrors', 'ScriptAnalyzerWarnings', 'ScriptAnalyzerFindingsAverage', 'TestsPassRate', 'TestCoverage', 'ComplexityAverage', 'NestingDepthAverage')
    [System.Collections.ArrayList]$MetricNames = @()

    Foreach ( $MetricsInput in $MetricsInputNames ) {
        If ( Get-VstsInput -Name $MetricsInput -AsBool ) {
            $Null = $MetricNames.Add($MetricsInput)
        }
    }

    return ($MetricNames -as [string[]])
}

Function Get-GateParamsFromInputs {
    [CmdletBinding()]
    Param()

    $InputsHashTable = @{
        SettingsGroup   = 'OverallMetrics'
    }
    If ( Get-VstsInput -Name 'SelectMetrics' -AsBool ) {
        $MetricNames = Get-MetricNamesFromInputs
        If ( $MetricNames ) {
            $InputsHashTable.Add('MetricName', $MetricNames)
        }
    }

    $CustomSettingsPath = Get-VstsInput -Name 'CustomSettingsPath'
    If ( $CustomSettingsPath -and ($CustomSettingsPath -match '\\\S+\.json$') ) {
        Test-CustomSettingsJson -Path $CustomSettingsPath -ErrorAction Stop
        $InputsHashTable.Add('CustomSettingsPath', $CustomSettingsPath)
    }

    return $InputsHashTable
}