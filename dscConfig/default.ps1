Configuration default {

    param(
    [int]
    $buildAgentCount = "4"
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


    }
}