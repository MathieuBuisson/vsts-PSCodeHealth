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
            $Result.GetType().Name | Should Be 'Hashtable'
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
            $Result.GetType().Name | Should Be 'Hashtable'
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
