
function Add-DcsConfiguration {
    [CmdletBinding()]
    param (
        [String]
        [Parameter(Mandatory)]
        $ResourceGroupName,

        [String]
        [Parameter(Mandatory)]
        $AutomationAccountName,

        [String]
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $SourcePath
    )

    begin {
        $ConfigurationName = $SourcePath.Split("\")[-1].Replace(".ps1", "")
    }

    process {
        Import-AzAutomationDscConfiguration -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -SourcePath $SourcePath -Force -Published
        $CompilationJob = Start-AzAutomationDscCompilationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -ConfigurationName $ConfigurationName

        while ($null -eq $CompilationJob.EndTime -and $null -eq $CompilationJob.Exception) {
            $CompilationJob = $CompilationJob | Get-AzAutomationDscCompilationJob
            Write-Output "Compiling..."
            Start-Sleep -Seconds 3
        }

        if($CompilationJob.Exception){
            Write-Output ("##vso[task.logissue type=error]{0}" -f $CompilationJob.Exception)

        }

        $CompilationJob | Get-AzAutomationDscCompilationJobOutput -Stream Any
    }
    end {
    }
}

Add-DcsConfiguration -ResourceGroupName vh-automation-dev -AutomationAccountName vh-automation-dev -SourcePath '.\dscConfig\default.ps1' -Verbose