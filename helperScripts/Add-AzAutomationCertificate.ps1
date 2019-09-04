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
Write-Output "Trying to fetch the certificate"

$cert = Get-AzAutomationCertificate -AutomationAccountName $automationAccountName -Name $certificateName -ResourceGroupName $automationAccountName -ErrorAction SilentlyContinue
if (!$cert) {
    New-AzAutomationCertificate -AutomationAccountName $automationAccountName -Name $certificateName -Path $certificatePath -Password $password -ResourceGroupName $automationAccountName
}
else {
    Write-Host ("Certificate with thumbprint {0} found" -f $cert.thumbprint)
}