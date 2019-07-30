Configuration default {

    $patCredential = Get-AzAutomationVariable -Name 'patToken'

    Import-DscResource -ModuleName VSTSAgent

    Node 'localhost' {

        xVSTSAgent VSTSAgent {
            Name              = 'Agent01'
            ServerUrl         = 'https://account.visualstudio.com'
            AccountCredential = $patCredential
            AgentDirectory    = 'C:\VSTSAgents'
            Work              = 'D:\VSTSAgentsWork\Agent01'
            Ensure            = 'Present'
        }
    }
}