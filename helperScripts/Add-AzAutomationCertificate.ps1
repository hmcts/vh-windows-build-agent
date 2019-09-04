[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $certificateName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $certificatePath,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $automationAccountName
)

$Password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
New-AzureRmAutomationCertificate -AutomationAccountName $automationAccountName -Name $certificateName -Path $certificatePath -Password $Password -ResourceGroupName $automationAccountName