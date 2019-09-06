Configuration default {

    param(
        [int]
        $buildAgentCount = "4"
    )

    $patCredential = Get-AutomationPSCredential -Name 'patToken'
    $vh_vsts_automation_dev_passphrase = Get-AutomationPSCredential -Name 'vh_vsts_automation_dev_passphrase'
    $vhVstsAutomationCertificateDev = Get-AutomationCertificate -Name 'vh_vsts_automation_dev'


    Import-DscResource -ModuleName VSTSAgent
    Import-DscResource -ModuleName xCertificate

    Node 'localhost' {


        File DirectoryCopy {
            Ensure          = "Present" # Ensure the directory is Present on the target node.
            Type            = "Directory" # The default is File.
            DestinationPath = "C:\temp"
        }

        Script ImportCrt
        {
            GetScript =
            {
                return @{
                    'Result' = "Not working." }
            }

            SetScript = {
                Write-Output $using:vhVstsAutomationCertificateDev.pspath
                Write-Output $using:vhVstsAutomationCertificateDev
                $using:vhVstsAutomationCertificateDev | Export-PfxCertificate -FilePath "C:\temp\vh_vsts_automation_dev.pfx" -Password $using:vh_vsts_automation_dev_passphrase
            }

            TestScript = {
                Test-Path "C:\temp\vh_vsts_automation_dev.pfx"
            }
        }

        xPfxImport CompanyCert
        {
            Thumbprint = $vhVstsAutomationCertificateDev.Thumbprint
            Path       = $vhVstsAutomationCertificateDev.pspath
            Location   = 'LocalMachine'
            Store      = 'My'
            Credential = $vh_vsts_automation_dev_passphrase
        }

        Script javaSDK {
            GetScript  =
            {
                @{
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                    Result     = ('True' -in (Test-Path "c:\Program Files\Java\jdk1.8.0_131\bin"))
                }
            }

            SetScript  =
            {
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
            }

            TestScript =
            {
                $Status = ('True' -in (Test-Path "c:\Program Files\Java\jdk1.8.0_131\bin"))
                $Status -eq $True
            }
        }

        Script VSBuildTools2019 {
            # Must return a hashtable with at least one key
            # named 'Result' of type String
            GetScript  = {

                Write-Verbose -Message "Detecting a previous installation of Visual Studio Community 2019"

                $x86Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
                $installedItemsX86 = Get-ItemProperty -Path $x86Path | Select-Object -Property DisplayName
                $x64Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
                $installedItemsX64 = Get-ItemProperty -Path $x64Path | Select-Object -Property DisplayName

                $installedItems = $installedItemsX86 + $installedItemsX64
                $installedItems = $installedItems | Select-Object -Property DisplayName -Unique
                $vsInstall = $installedItems | Where-Object -FilterScript {
                    $_ -match "Visual Studio Community 2019"
                }

                Return @{
                    Result = [string]$vsInstall
                }
            }

            # Must return a boolean: $true or $false
            TestScript = {
                Write-Verbose -Message "Detecting a previous installation of Visual Studio Community 2019"

                $x86Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
                $installedItemsX86 = Get-ItemProperty -Path $x86Path | Select-Object -Property DisplayName
                $x64Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
                $installedItemsX64 = Get-ItemProperty -Path $x64Path | Select-Object -Property DisplayName

                $installedItems = $installedItemsX86 + $installedItemsX64
                $installedItems = $installedItems | Select-Object -Property DisplayName -Unique
                $vsInstall = $installedItems | Where-Object -FilterScript {
                    $_ -match "Visual Studio Community 2019"
                }
                if ($vsInstall) {
                    Write-Verbose -Message "Visual Studio Community 2019 installed"
                    return $true;
                }
                else {
                    Write-Verbose -Message "Visual Studio Community 2019 not installed"
                    return $false;
                }
            }

            # Returns nothing
            SetScript  = {
                $vsInstaller = "https://aka.ms/vs/16/release/vs_community.exe"
                $VSBuildToolWorkloads = @(
                    "Microsoft.VisualStudio.Workload.NetWeb",
                    "Microsoft.VisualStudio.Workload.NetCoreTools",
                    "Microsoft.Net.Core.Component.SDK.2.2"
                )

                $ExecutablePath = "C:\temp\vs_community.exe"
                Invoke-WebRequest -Uri $vsInstaller -OutFile $ExecutablePath
                $installer = Get-Item -Path $ExecutablePath
                $Workloads = $VSBuildToolWorkloads

                if ($installer) {
                    $workloadArgs = ""
                    foreach ($workload in $Workloads) {
                        $workloadArgs += " --add $workload"
                    }
                    Write-Verbose -Message "Installing Visual Studio Community 2019"
                    Start-Process -FilePath $ExecutablePath -ArgumentList ('--quiet' + ' --includeRecommended' + $workloadArgs) -Wait -PassThru -Verb runAs
                }
                else {
                    throw "The Installer could not be found at $ExecutablePath"
                }
            }
        }

        For ($i = 1; $i -le $buildAgentCount; $i++) {

            $VSTSAgent = "VSTSAgent" + $i

            xVSTSAgent $VSTSAgent {
                Name              = 'Agent' + $i
                ServerUrl         = 'https://hmctsreform.visualstudio.com'
                Pool              = 'vh-pool-dev'
                AccountCredential = $patCredential
                AgentDirectory    = 'F:\VSTSAgent'+ $i
                Ensure            = 'Present'
            }
        }
    }
}
