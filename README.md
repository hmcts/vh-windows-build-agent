# vh-windows-build-agent
Contains scripts for creating Windows Image for Jenkins slave using packer
## Install packer
Follow [Getting Started guide](https://www.packer.io/intro/getting-started/install.html) to install packer.
### On windows 
```bash
choco install packer
```
Once packer has been installed run using packer using PowerSHell and pass json definition file.
```bash
$timestamp = Get-Date -Format yyyyMMddHHMMss 
 & packer build -machine-readable `
 -var "time_stamp=$timestamp" `
 -var-file AAD_Variables.json `
  windowsagent.json
```
`AAD_Variables.json` contains sensitive information that is used for authentication. The details are specific to Azure tenant and subscription. Once image has been created it will be accessible only from Azure subscription specified in `AAD_Variables.json`
```bash
{
    "SPN_client_id": "xxxx",
    "SPN_client_secret": "xxxx",
    "AAD_tenant_id": "xxxx",
    "Azure_subscription_id": "xxxx"
}
```

