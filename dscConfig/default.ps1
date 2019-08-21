Configuration default {

    param(
        [int]
        $buildAgentCount = "4",
        $vsInstaller = "https://aka.ms/vs/15/release/vs_buildtools.exe"
    )

    $patCredential = Get-AutomationPSCredential -Name 'patToken'

    Import-DscResource -ModuleName VSTSAgent
    Import-DscResource -ModuleName VisualStudioDSC

    Node 'local' {

        For ($i = 1; $i -le $buildAgentCount; $i++) {

            $VSTSAgent = "VSTSAgent" + $i

            xVSTSAgent $VSTSAgent {
                Name              = 'Agent' + $i
                ServerUrl         = 'https://hmctsreform.visualstudio.com'
                Pool              = 'vh-pool-dev'
                AccountCredential = $patCredential
                AgentDirectory    = 'C:\VSTSAgent'+ $i
                Ensure            = 'Present'
            }
        }

        File DirectoryCopy {
            Ensure          = "Present" # Ensure the directory is Present on the target node.
            Type            = "Directory" # The default is File.
            DestinationPath = "C:\temp"
        }

        Script DownloadExe {
            GetScript  =
            {
                @{
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                    Result     = ('True' -in (Test-Path "C:\temp\vs_buildtools.exe"))
                }
            }

            SetScript  =
            {
                Invoke-WebRequest -Uri "https://aka.ms/vs/15/release/vs_buildtools.exe" -OutFile "C:\temp\vs_buildtools.exe"
            }

            TestScript =
            {
                $Status = ('True' -in (Test-Path "C:\temp\vs_buildtools.exe"))
                $Status -eq $True
            }
        }

        VSInstall VisualStudio2017 {
            ExecutablePath = "C:\temp\vs_buildtools.exe"
            Workloads      = "Microsoft.VisualStudio.Workload.MSBuildTools, Microsoft.Net.Core.Component.SDK, Microsoft.Net.ComponentGroup.4.6.2.DeveloperTools, Microsoft.VisualStudio.Workload.WebBuildTools, Microsoft.VisualStudio.Workload.NodeBuildTools, Microsoft.Net.Component.3.5.DeveloperTools, Microsoft.VisualStudio.Component.TestTools.BuildTools, Microsoft.VisualStudio.Component.TypeScript.2.8, Microsoft.VisualStudio.Component.TestTools.BuildTools, Microsoft.VisualStudio.Workload.MSBuildTools"
            Ensure         = 'Present'
        }
    }
}