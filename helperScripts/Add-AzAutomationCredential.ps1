

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $user,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $password,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $automationAccountName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $automationAccountCredentialName
)

$user = $user
$pw = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pw
New-AzAutomationCredential -AutomationAccountName $automationAccountName -Name $automationAccountCredentialName -Value $cred -ResourceGroupName $automationAccountName
