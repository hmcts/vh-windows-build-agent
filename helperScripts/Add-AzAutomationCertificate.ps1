[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $certificateName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $certificatePassword,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $certificatePath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $automationAccountName
)

$password = ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force

$cert = Get-AzAutomationCertificate -AutomationAccountName $automationAccountName -Name $certificateName -ResourceGroupName $automationAccountName
if (!$cert) {
    New-AzAutomationCertificate -AutomationAccountName $automationAccountName -Name $certificateName -Path $certificatePath -Password $password -ResourceGroupName $automationAccountName
}