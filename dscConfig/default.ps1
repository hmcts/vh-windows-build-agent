Configuration default {

    $patCredential = Get-AutomationPSCredential -Name 'patToken'

    Import-DscResource -ModuleName VSTSAgent

    Node 'local' {

        xVSTSAgent VSTSAgent {
            Name              = 'Agent01'
            ServerUrl         = 'https://hmctsreform.visualstudio.com/VirtualHearings'
            Pool               = 'vh-pool-dev'
            AccountCredential = $patCredential
            AgentDirectory    = 'C:\VSTSAgents'
            Work              = 'D:\VSTSAgentsWork\Agent01'
            Ensure            = 'Present'
        }
    }
}