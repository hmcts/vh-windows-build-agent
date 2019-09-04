$keyEncryptionKeyName = 'vhvstsagentdiskkey';
$KeyVaultName = "vh-vsts-agent"

$keyEncryptionKey = Get-AzKeyVaultKey -VaultName $KeyVaultName -Name $keyEncryptionKeyName

if (!$keyEncryptionKey) {
    $keyEncryptionKey = Add-AzKeyVaultKey -VaultName $KeyVaultName -Name $keyEncryptionKeyName -Destination "Software"
}

Write-Output ("##vso[task.setvariable variable=KeyEncryptionKeyURL]{0}" -f $keyEncryptionKey.id)