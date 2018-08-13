
function Get-InstallMedia {
    [CmdletBinding()]
    param (
        $source,
        $destination
    )
    
    begin {
        $client = new-object System.Net.WebClient
        #$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
        $client.downloadFile($source, $destination)
    }
    
    process {
        $client.downloadFile($source, $destination)
    }
    
    end {
    }
}

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

### Install Git
Write-Output "Installing Git"
$source = "https://github.com/git-for-windows/git/releases/latest"
$latestRelease = Invoke-WebRequest -UseBasicParsing $source -Headers @{"Accept" = "application/json"}
$json = $latestRelease.Content | ConvertFrom-Json
$latestVersion = $json.tag_name
$versionHead = $latestVersion.Substring(1, $latestVersion.IndexOf("windows") - 2)
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

Write-Output "Installing MS Build tools 2017..."

#$VS_CHANNEL_URI = "https://aka.ms/vs/15/release/799c44140/channel"
$VS_BUILDTOOLS_URI = "https://aka.ms/vs/15/release/vs_buildtools.exe"
#$VS_BUILDTOOLS_SHA256 = "FA29EB83297AECADB0C4CD41E54512C953164E64EEDD9FB9D3BF9BD70C9A2D29"

# Download log collection utility
Invoke-WebRequest -Uri "https://aka.ms/vscollect.exe" -OutFile D:\collect.exe

# Download vs_buildtools.exe
Invoke-WebRequest -Uri $VS_BUILDTOOLS_URI -OutFile D:\vs_buildtools.exe
#if ((Get-FileHash -Path C:\vs_buildtools.exe -Algorithm SHA256).Hash -ne $env:VS_BUILDTOOLS_SHA256) { throw 'Download hash does not match' }

# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools
# Install Visual Studio Build Tools
$p = Start-Process -Wait -PassThru -FilePath D:\vs_buildtools.exe -ArgumentList '--quiet --nocache --wait --installPath C:\BuildTools';
if ($ret = $p.ExitCode) { D:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

# Install VS woarkloads
Write-Output "Installing Visual studio workloads..."
$p = Start-Process -Wait -PassThru -FilePath D:\vs_buildtools.exe -ArgumentList "modify --quiet --nocache --wait --installPath C:\BuildTools",
"--add Microsoft.VisualStudio.Workload.MSBuildTools",
"--add Microsoft.Net.Core.Component.SDK",
"--add Microsoft.Net.ComponentGroup.4.6.2.DeveloperTools",
"--add Microsoft.VisualStudio.Workload.WebBuildTools",
"--add Microsoft.VisualStudio.Workload.NodeBuildTools",
"--add Microsoft.Net.Component.3.5.DeveloperTools",
"--add Microsoft.VisualStudio.Component.TestTools.BuildTools",
"--add Microsoft.VisualStudio.Component.TypeScript.2.8",
"--add Microsoft.VisualStudio.Component.TestTools.BuildTools",
"--add Microsoft.VisualStudio.Workload.MSBuildTools"; 
if ($ret = $p.ExitCode) { D:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

Write-Output "Creating adding MSBuild to path variable"
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";C:\BuildTools\MSBuild\15.0\Bin", "Machine")

Write-Output "Installing .Net Core 2.1.3..."
$source = "https://download.microsoft.com/download/4/0/9/40920432-3302-47a8-b13c-bbc4848ad114/dotnet-sdk-2.1.302-win-x64.exe"
$destination = "D:\dotnet-sdk-2.1.302-win-x64.exe"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
$client.downloadFile($source, $destination)
$proc = Start-Process -FilePath $destination -ArgumentList "/Install /q" -Wait -PassThru
$proc.WaitForExit()

Write-Output "Installing chocolety..."

Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Output "Installing nuget..."
choco install -y nuget.commandline 

Write-Output "Installing .Net 4.6.2..."
choco install -y netfx-4.6.2-devpack
choco install -y dotnet4.6.2