# Load the VSTS task SDK
$SdkPath = (Resolve-Path -Path "$PSScriptRoot\..\task\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1").Path
Import-Module $SdkPath -ArgumentList @{ NonInteractive = $True } -Force

$Sut = (Resolve-Path -Path "$PSScriptRoot\..\task\Helpers.ps1").Path
. "$Sut"

Describe 'Get-PSCodeHealthParamsFromInputs' {

    Mock Get-VstsInput -ParameterFilter { $Name -eq 'SourceCodePath' } { 'Any' }
    Mock Get-VstsInput -ParameterFilter { $Name -eq 'TestsPath' } { 'Any' }
    Mock Get-VstsInput -ParameterFilter { $Name -eq 'Recurse' } { $True }

    Context 'Without "Exclude" input' {

        $Result = Get-PSCodeHealthParamsFromInputs

        It 'Should return a [Hashtable] object' {
            $Result | Should BeOfType [Hashtable]
        }
        It 'Should contain the expected value for "Path"' {
            $Result.Path | Should Be 'Any'
        }
        It 'Should contain the expected value for "TestsPath"' {
            $Result.TestsPath | Should Be 'Any'
        }
        It 'Should contain the expected value for "Recurse"' {
            $Result.Recurse | Should Be $True
        }
        It 'Should not contain any key for "Exclude"' {
            $Result.ContainsKey('Exclude') | Should Be $False
        }
    }
    Context 'Without "Exclude" input' {

        Mock Get-VstsInput -ParameterFilter { $Name -eq 'Exclude' } {
            @'
*.psd1
*.psm1
'@
        }
        $Result = Get-PSCodeHealthParamsFromInputs

        It 'Should return a [Hashtable] object' {
            $Result | Should BeOfType [Hashtable]
        }
        It 'Should contain the expected value for "Path"' {
            $Result.Path | Should Be 'Any'
        }
        It 'Should contain the expected value for "TestsPath"' {
            $Result.TestsPath | Should Be 'Any'
        }
        It 'Should contain the expected value for "Recurse"' {
            $Result.Recurse | Should Be $True
        }
        It 'Should contain an "Exclude" with an array value' {
            $Result.Exclude.GetType().Name | Should Match '\[\]'
        }
        It 'Should contain an "Exclude" with 2 elements' {
            $Result.Exclude.Count | Should Be 2
        }
        It 'Should contain an "Exclude" with 2 expected values' {
            Foreach ( $Element in $Result.Exclude ) {
                $Element | Should BeLike '*ps*1'
            }
        }
    }
}

Describe 'Write-PSCodeHealthParamsFromInputs' {

    Context 'The value of "InputsHashTable" is an empty [Hashtable]' {

        $TestHashtable = @{}

        It 'Should not throw' {
            { Write-PSCodeHealthParamsFromInputs -InputsHashTable $TestHashtable } |
                Should Not Throw
        }
    }
    Context 'The value of "InputsHashTable" is $Null' {

        $TestHashtable = $Null

        It 'Should not throw' {
            { Write-PSCodeHealthParamsFromInputs -InputsHashTable $TestHashtable } |
                Should Not Throw
        }
        It 'Should return $Null' {
            Write-PSCodeHealthParamsFromInputs -InputsHashTable $TestHashtable |
                Should BeNullOrEmpty
        }
    }
    Context 'The value "InputsHashtable" is a [Hashtable] with multiple key/value pairs' {

        $TestHashtable = @{
            TestKey  = 'TestValue'
            TestKey2 = 'TestValue2'
        }
        $Result = Write-PSCodeHealthParamsFromInputs -InputsHashTable $TestHashtable

        It 'Should return an array of [string]' {
            $Result | Should BeOfType [string]
        }
        It 'Should return 2 objects' {
            $Result.Count | Should Be 2
        }
        It 'Should return the expected values in each element' {
            Foreach ( $ActualMessage in $Result ) {
                $ActualMessage |
                    Should Match 'Value of \[TestKey\S*\] : TestValue\S*'
            }
        }
    }
}

Describe 'Get-MetricNamesFromInputs' {

    $MetricsInputNames = @('LinesOfCodeAverage', 'ScriptAnalyzerFindingsTotal', 'ScriptAnalyzerErrors', 'ScriptAnalyzerWarnings', 'ScriptAnalyzerFindingsAverage', 'TestsPassRate', 'TestCoverage', 'ComplexityAverage', 'NestingDepthAverage')

    Context 'None of the metric inputs are selected' {

        Foreach ( $MetricsInput in $MetricsInputNames ) {
            Mock Get-VstsInput -ParameterFilter { $Name -eq $MetricsInput } { $False }
        }

        It 'Should return an empty object' {
            Get-MetricNamesFromInputs | Should BeNullOrEmpty
        }
    }
    Context '4 of the metric inputs are selected' {

        $SelectedMetrics = @('LinesOfCodeAverage', 'ScriptAnalyzerErrors', 'TestsPassRate', 'ComplexityAverage')
        Foreach ( $MetricsInput in $MetricsInputNames ) {
            Mock Get-VstsInput -ParameterFilter { $Name -eq $MetricsInput } { $MetricsInput -in $SelectedMetrics }
        }
        $Result = Get-MetricNamesFromInputs

        It 'Should return an array of [string]' {
            $Result | Should BeOfType [string]
        }
        It 'Should return 4 elements' {
            $Result.Count | Should Be 4
        }
        It 'Should return elements matching the selected metric inputs' {
            Foreach ( $MetricName in $Result ) {
                $MetricName | Should Match 'LinesOfCodeAverage|ScriptAnalyzerErrors|TestsPassRate|ComplexityAverage'
            }
        }
        It 'Should not return elements matching unselected metric inputs' {
            Foreach ( $MetricName in $Result ) {
                $MetricName | Should Not Match 'ScriptAnalyzerWarnings|TestCoverage|NestingDepthAverage'
            }
        }
    }
}

Describe 'Get-GateParamsFromInputs' {

    Context '"SelectMetrics" input is not selected' {

        Mock Get-VstsInput -ParameterFilter { $Name -eq $SelectMetrics } { $False }
        $Result = Get-GateParamsFromInputs

        It 'Should return a [Hashtable] object' {
            $Result | Should BeOfType [Hashtable]
        }
        It 'Should return a [HashTable] with only 1 key' {
            $Result.Keys.Count | Should Be 1
        }
        It 'Should contain the expected value for "SettingsGroup"' {
            $Result.SettingsGroup | Should Be 'OverallMetrics'
        }
    }
    Context '"SelectMetrics" input is not selected' {

        Mock Get-VstsInput -ParameterFilter { $Name -eq 'SelectMetrics' } { $True }
        Mock Get-MetricNamesFromInputs { [string[]]('LinesOfCodeAverage', 'ScriptAnalyzerErrors', 'TestsPassRate', 'ComplexityAverage') }
        $Result = Get-GateParamsFromInputs

        It 'Should return a [Hashtable] object' {
            $Result | Should BeOfType [Hashtable]
        }
        It 'Should return a [HashTable] with 5 keys' {
            $Result.Keys.Count | Should Be 2
        }
        It 'Should have the expected number of elements in the "MetricName" value' {
            $Result.MetricName.Count | Should Be 4
        }
        It 'Should return a "MetricName" value with elements matching the selected metric inputs' {
            Foreach ( $MetricName in $Result.MetricName ) {
                $MetricName | Should Match 'LinesOfCodeAverage|ScriptAnalyzerErrors|TestsPassRate|ComplexityAverage'
            }
        }
    }
}