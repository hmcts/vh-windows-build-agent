Configuration default {

    param(
    [int]
    $buildAgentCount = "5"
    )

    $patCredential = Get-AutomationPSCredential -Name 'patToken'

    Import-DscResource -ModuleName VSTSAgent

    Node 'local' {



        For ($i = 0; $i -le $buildAgentCount; $i++) {
            xVSTSAgent VSTSAgent {
                Name              = 'Agent' + $i
                ServerUrl         = 'https://hmctsreform.visualstudio.com'
                Pool              = 'vh-pool-dev'
                AccountCredential = $patCredential
                AgentDirectory    = 'C:\VSTSAgent'+ $i
                Ensure            = 'Present'
            }
        }


    }
}