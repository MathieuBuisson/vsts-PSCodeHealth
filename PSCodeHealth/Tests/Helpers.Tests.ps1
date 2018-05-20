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
    Context 'With "GenerateHtmlReport" and "CustomSettingsPath" inputs' {

        Mock Get-VstsInput -ParameterFilter { $Name -eq 'GenerateHtmlReport' } { $True }
        Mock Get-VstsInput -ParameterFilter { $Name -eq 'HtmlReportPath' } { 'Any' }
        [string]$SettingsFilePath = "$PSScriptRoot\TestData\Valid.json"
        Mock Get-VstsInput -ParameterFilter { $Name -eq 'CustomSettingsPath' } { $SettingsFilePath }
        Mock Test-CustomSettingsJson { } -Verifiable
        $Result = Get-PSCodeHealthParamsFromInputs

        It 'Should return a [Hashtable] object' {
            $Result | Should BeOfType [Hashtable]
        }
        It 'Should contain the expected value for "HtmlReportPath"' {
            $Result.HtmlReportPath | Should Be 'Any'
        }
        It 'Should contain the expected value for "CustomSettingsPath"' {
            $Result.CustomSettingsPath | Should Be $SettingsFilePath
        }
        It 'Should call "Test-CustomSettingsJson" to validate the custom settings file' {
            Assert-VerifiableMock
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
        It 'Should return a [HashTable] with 2 keys' {
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
    Context '"CustomSettingsPath" input has a value' {

        Mock Get-VstsInput -ParameterFilter { $Name -eq 'SelectMetrics' } { $True }
        Mock Get-MetricNamesFromInputs { [string[]]('LinesOfCodeAverage', 'ScriptAnalyzerErrors', 'TestsPassRate', 'ComplexityAverage') }
        [string]$FilePath = "$PSScriptRoot\TestData\Valid.json"
        Mock Get-VstsInput -ParameterFilter { $Name -eq 'CustomSettingsPath' } { $FilePath }
        $Result = Get-GateParamsFromInputs

        It 'Should return a [Hashtable] object' {
            $Result | Should BeOfType [Hashtable]
        }
        It 'Should return a [HashTable] with 3 keys' {
            $Result.Keys.Count | Should Be 3
        }
        It 'Should return a [HashTable] with a "CustomSettingsPath" key' {
            $Result.ContainsKey('CustomSettingsPath') | Should Be $True
        }
        It 'Should return a [HashTable] with the expected "CustomSettingsPath" value' {
            $Result.CustomSettingsPath | Should BeLike '*\TestData\Valid.json'
        }
    }
}

Describe 'Test-CustomSettingsJson' {

    Context 'The file specified does not contain valid JSON' {

        $InvalidJson = "$PSScriptRoot\TestData\Invalid.json"

        It 'Should throw "An error occurred when attempting to parse JSON data"' {
            { Test-CustomSettingsJson $InvalidJson } |
                Should Throw "An error occurred when attempting to parse JSON data"
        }
    }
    Context 'The JSON content is missing a metrics group' {

        $MissingGroup = "$PSScriptRoot\TestData\MissingGroup.json"

        It 'Should throw that the group PerFunctionMetrics is missing from the JSON' {
            { Test-CustomSettingsJson $MissingGroup } |
                Should Throw 'The metrics group PerFunctionMetrics is missing from the JSON'
        }
    }
    Context "The JSON content contains a rule for a metric which doesn't exist in PSCodeHealth" {

        $InvalidMetric = "$PSScriptRoot\TestData\InvalidMetric.json"

        It "Should throw that the custom rule doesn't match a valid metric name" {
            { Test-CustomSettingsJson $InvalidMetric } |
                Should Throw "The custom rule [Invalid] does not match a valid metric name"
        }
    }
    Context "The JSON content contains 2 valid rules" {

        $Valid = "$PSScriptRoot\TestData\Valid.json"
        $Results = Test-CustomSettingsJson $Valid

        It 'Should return nothing' {
            $Results | Should BeNullOrEmpty
        }
    }
}

Describe 'Get-ComplianceFailureAction' {

    Context '"ComplianceFailureAction" input has a value of "fail"' {

        Mock Get-VstsInput -ParameterFilter { $Name -eq 'ComplianceFailureAction' } { 'fail' }
        $Result = Get-ComplianceFailureAction

        It 'Should return a [string]' {
            $Result | Should BeOfType [string]
        }
        It 'Should return the value "fail"' {
            $Result | Should Be 'fail'
        }
    }
}

Describe 'Invoke-ComplianceFailureAction' {

    $TestComplianceResults = @{ MetricName = 'Test'; Value = 11; FailThreshold = 10; HigherIsBetter = $False },
    @{ MetricName = 'Test2'; Value = 19; FailThreshold = 20; HigherIsBetter = $True }

    $ExpectedMessage = 'Code metric [Test] with value [11] is above quality gate set to [10].'
    $ExpectedMessage2 = 'Code metric [Test2] with value [19] is below quality gate set to [20].'
    Mock Write-VstsTaskWarning { } -ParameterFilter { $Message -eq $ExpectedMessage }
    Mock Write-VstsTaskWarning { } -ParameterFilter { $Message -eq $ExpectedMessage2 }

    Context '"FailureAction" input has a value of "warning"' {

        $Result = Invoke-ComplianceFailureAction -FailureAction 'warning' -ComplianceResult $TestComplianceResults

        It 'Should return nothing' {
            $Result | Should BeNullOrEmpty
        }
        It 'Should call "Write-VstsTaskWarning" with the expected message for metric "Test"' {
            Assert-MockCalled Write-VstsTaskWarning -Scope 'Context' -ParameterFilter { $Message -eq $ExpectedMessage } -Exactly 1
        }
        It 'Should call "Write-VstsTaskWarning" with the expected message for metric "Test2"' {
            Assert-MockCalled Write-VstsTaskWarning -Scope 'Context' -ParameterFilter { $Message -eq $ExpectedMessage2 } -Exactly 1
        }
    }
    Context '"FailureAction" input has a value of "fail"' {

        $ExpectedErrorMessage = 'The following metric(s) failed the quality gate : Test, Test2'
        Mock Write-VstsTaskError { } -ParameterFilter { $Message -eq $ExpectedErrorMessage }
        Mock Write-VstsSetResult { } -ParameterFilter { $Message -eq $ExpectedErrorMessage }
        $Result = Invoke-ComplianceFailureAction -FailureAction 'fail' -ComplianceResult $TestComplianceResults

        It 'Should return nothing' {
            $Result | Should BeNullOrEmpty
        }
        It 'Should call "Write-VstsTaskWarning" with the expected message for metric "Test"' {
            Assert-MockCalled Write-VstsTaskWarning -Scope 'Context' -ParameterFilter { $Message -eq $ExpectedMessage } -Exactly 1
        }
        It 'Should call "Write-VstsTaskWarning" with the expected message for metric "Test2"' {
            Assert-MockCalled Write-VstsTaskWarning -Scope 'Context' -ParameterFilter { $Message -eq $ExpectedMessage2 } -Exactly 1
        }
        It 'Should call "Write-VstsTaskError" with the expected message' {
            Assert-MockCalled Write-VstsTaskError -Scope 'Context' -ParameterFilter { $Message -eq $ExpectedErrorMessage } -Exactly 1
        }
        It 'Should call "Write-VstsSetResult" with the expected message' {
            Assert-MockCalled Write-VstsSetResult -Scope 'Context' -ParameterFilter { $Message -eq $ExpectedErrorMessage } -Exactly 1
        }
    }
}