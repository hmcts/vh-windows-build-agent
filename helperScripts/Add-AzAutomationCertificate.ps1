[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $certificateName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $certificatePassword,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $certificatePath,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $automationAccountName
)

$Password = ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force
New-AzAutomationCertificate -AutomationAccountName $automationAccountName -Name $certificateName -Path $certificatePath -Password $Password -ResourceGroupName $automationAccountName