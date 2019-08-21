Configuration default {

    param(
        [int]
        $buildAgentCount = "4",
        $vsInstaller = "https://aka.ms/vs/15/release/vs_buildtools.exe"
    )

    $patCredential = Get-AutomationPSCredential -Name 'patToken'

    Import-DscResource -ModuleName VSTSAgent

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

        File DirectoryCopy
        {
            Ensure = "Present" # Ensure the directory is Present on the target node.
            Type = "Directory" # The default is File.
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
                Invoke-WebRequest -Uri $vsInstaller -OutFile "C:\temp\vs_buildtools.exe"
            }

            TestScript =
            {
                $Status = ('True' -in (Test-Path "C:\temp\vs_buildtools.exe"))
                $Status -eq $True
            }
        }


    }
}