[cmdletbinding()]
param (
    [parameter(Mandatory)]
    [string]
    $DevOpsUrl,

    [parameter(Mandatory)]
    [string]
    $PAT,

    [parameter(Mandatory)]
    [string]
    $AgentPool,

    [parameter()]
    [string]
    $AgentName = "agent",

    [parameter()]
    [string]
    $AgentPath = (Join-Path $env:SystemDrive "Agent"),

    [parameter()]
    [int]
    $InstanceCount = 1
)

begin {
    $env:VSTS_AGENT_HTTPTRACE = $true
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ConfirmPreference = "None"
    $ProgressPreference = "SilentlyContinue"

    Start-Transcript

    Write-Verbose "Getting latest Azure Pipelines Release Manifest"
    $AgentMetaObject = Invoke-RestMethod https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest
    Write-Verbose "Found Azure Pipelines Agent $($AgentMetaObject.tag_name)"

    Write-Verbose "Getting list of assets within the release"
    $ReleaseAssets = Invoke-RestMethod $AgentMetaObject.assets.where{ $_.name -eq "assets.json" }.browser_download_url

    if ($IsWindows -in @($true, $null)) {
        $platform = "win-x64"
    } elseif ( $IsLinux) {
        $platform = "linux-x64"
    } else {
        $platform = "osx-x64"
    }

    Write-Verbose "Downloading the agent package for $platform"

    $Package = $ReleaseAssets.where{ $_.platform -eq $platform }
    $AgentArchive = Join-Path $env:temp (Split-Path $Package.downloadUrl -Leaf)
    Invoke-WebRequest $Package.downloadUrl -Out $AgentArchive
}

process {
    foreach ($instance in 1..$InstanceCount) {
        $CurrentAgentFolder = Join-Path $AgentPath "$instance"
        if (Test-Path $CurrentAgentFolder) {
            Remove-Item -Path $CurrentAgentFolder -Force -Recurse
        }

        New-Item -ItemType Directory -Force -Path $CurrentAgentFolder | Out-Null

        Write-Verbose "Extracting Agent Package to $CurrentAgentFolder"
        Expand-Archive -Path $AgentArchive -DestinationPath $CurrentAgentFolder

        Write-Verbose "Executing: $CurrentAgentFolder/config.cmd --unattended --url $DevOpsUrl --auth pat --token *** --pool `"$AgentPool`" --agent `"$AgentName $instance`" --acceptTeeEula --runAsService --replace"

        [scriptblock]::Create("$CurrentAgentFolder/config.cmd --unattended --url $DevOpsUrl --auth pat --token $PAT --pool `"$AgentPool`" --agent `"$AgentName $instance`" --acceptTeeEula --runAsService --replace").invoke()
    }
}

end {

    if ($platform -eq "win-x64") {
        [Environment]::SetEnvironmentVariable("LCOW_SUPPORTED", "1", "Machine")

        $Config = @{ experimental = $true }
        $config | ConvertTo-Json | Set-Content C:\ProgramData\docker\config\daemon.json -Encoding ascii -Force

        Write-Verbose "Getting latest LCOW Release Manifest"
        $LCOWMetaObject = (Invoke-RestMethod https://api.github.com/repos/linuxkit/lcow/releases) | Select-Object -First 1
        Write-Verbose "Found LCOW version $($LCOWMetaObject.tag_name)"

        $PackageUrl = $LCOWMetaObject.assets.where{ $_.name -eq "release.zip" }.browser_download_url
        $ReleaseAsset = Invoke-RestMethod $PackageUrl

        $LCOWArchive = Join-Path $env:temp (Split-Path $PackageUrl -Leaf)
        Invoke-WebRequest $ReleaseAsset -Out $LCOWArchive

        Write-Verbose "Extracting LCOW to $Env:ProgramFiles\Linux Containers\."
        Expand-Archive $LCOWArchive -DestinationPath "$Env:ProgramFiles\Linux Containers\."

        $PipeAcl = [System.IO.Directory]::GetAccessControl('\\.\pipe\docker_engine')
        $PipeAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule("Network Service", 'FullControl', 'Allow')
        $null = $PipeAcl.AddAccessRule($PipeAccessRule)
        [System.IO.Directory]::SetAccessControl('\\.\pipe\docker_engine', $PipeAcl)

        docker image prune

        Restart-Computer -Force
    }

    Stop-Transcript
}
