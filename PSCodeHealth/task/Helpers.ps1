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
        "Value of input [$($InputEntry.Key)] : $($InputEntry.Value)"
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