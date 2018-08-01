

$rgName = "vh-packer-image"
$location = "UK South"

New-AzureRmResourceGroup -Name $rgName -Location $location

## SP used for creating the image

$sp = Get-AzureRmADServicePrincipal -SearchString dcd_devopsoctopus | Where-Object DisplayName -EQ dcd_devopsoctopus
$securePassword = "ElL1YQoT8kbB03N3qVmE"
$sp.applicationId
$sp.id

$sub = Get-AzureRmSubscription | Where-Object Name -EQ "Reform-CFT-VH-Dev"
$sub.TenantId
$sub.SubscriptionId


[Environment]::SetEnvironmentVariable('PATH', ($env:JAVA_HOME + '\\bin;' + $env:PATH)), [EnvironmentVariableTarget]::Machine

$path = (([System.Environment]::GetEnvironmentVariable("PSModulePath", "Machine"))
[System.Environment]::SetEnvironmentVariable("PSModulePath", $path +";C:\Program Files\Fabrikam\Modules", "Machine"))

& packer build windowsagent.json 