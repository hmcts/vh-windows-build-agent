<#
### Install PowerShell 6
Write-Output "Installing PS 6"
#Set-ExecutionPolicy Unrestricted -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Default workspace location
Set-Location C:\
$source = "https://github.com/PowerShell/PowerShell/releases/download/v6.0.3/PowerShell-6.0.3-win-x64.msi"
$destination = "D:\PowerShell-6.0.3-win-x64.msi"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
$client.downloadFile($source, $destination)
$proc = Start-Process -FilePath $destination -ArgumentList "/q" -Wait -PassThru
$proc.WaitForExit()
#>

### Download and Install Java
Write-Output "Installing Java"
#Set-ExecutionPolicy Unrestricted -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Default workspace location
Set-Location C:\
$source = "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-windows-x64.exe"
$destination = "D:\jdk-8u131-windows-x64.exe"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
$client.downloadFile($source, $destination)
$proc = Start-Process -FilePath $destination -ArgumentList "/s" -Wait -PassThru
$proc.WaitForExit()
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "c:\Program Files\Java\jdk1.8.0_131", "Machine")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";c:\Program Files\Java\jdk1.8.0_131\bin", "Machine")
$Env:Path += ";c:\Program Files\Java\jdk1.8.0_131\bin"
#Disable git credential manager, get more details in https://support.cloudbees.com/hc/en-us/articles/221046888-Build-Hang-or-Fail-with-Git-for-Windows
#git config --system --unset credential.helper

<#### Install Maven
Write-Output "Installing Maven"
$source = "https://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.zip"
$destination = "D:\maven.zip"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace($destination)
mkdir 'C:\Program Files\apache-maven-3.5.2'
$destination = $shell_app.namespace('C:\Program Files')
$destination.Copyhere($zip_file.items(), 0x14)
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";C:\Program Files\apache-maven-3.5.2\bin", "Machine")
$Env:Path += ";C:\Program Files\apache-maven-3.5.2\bin"
#>


### Install Git
Write-Output "Installing Git"
$source = "https://github.com/git-for-windows/git/releases/latest"
$latestRelease = Invoke-WebRequest -UseBasicParsing $source -Headers @{"Accept"="application/json"}
$json = $latestRelease.Content | ConvertFrom-Json
$latestVersion = $json.tag_name
$versionHead = $latestVersion.Substring(1, $latestVersion.IndexOf("windows")-2)
$source = "https://github.com/git-for-windows/git/releases/download/v${versionHead}.windows.1/Git-${versionHead}-64-bit.exe"
$destination = "D:\Git-${versionHead}-64-bit.exe"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)
$proc = Start-Process -FilePath $destination -ArgumentList "/VERYSILENT" -Wait -PassThru
$proc.WaitForExit()
$Env:Path += ";C:\Program Files\Git\cmd"
#Disable git credential manager, get more details in https://support.cloudbees.com/hc/en-us/articles/221046888-Build-Hang-or-Fail-with-Git-for-Windows
git config --system --unset credential.helper

### Install Win32 OpenSSH
Write-output "Installing Win32 OpenSSH"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Default workspace location
Set-Location C:\
$source = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.7.2.0p1-Beta/OpenSSH-Win64.zip"
$destination = "D:\OpenSSH-Win64.zip"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
$client.downloadFile($source, $destination)
Expand-Archive -Path $destination -DestinationPath 'C:\Program Files\' -Force
powershell.exe -ExecutionPolicy Bypass -File 'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'
$proc.WaitForExit()

Write-Output "Adding Firewall exception"
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

Write-Output "Setup sshd and ssh-agent to auto-start"
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic

#Write-Output "Generalizing VM"
#& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit
#Write-Output "Waiting for VM to be ready"
#while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }