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

        Write-Verbose "Extracting Agent Package to $CurrentAgentFolder" -Verbose
        Expand-Archive -Path $AgentArchive -DestinationPath $CurrentAgentFolder

        Write-Verbose "Executing: $CurrentAgentFolder/config.cmd --unattended --url $DevOpsUrl --auth pat --token *** --pool `"$AgentPool`" --agent `"$AgentName $instance`" --acceptTeeEula --runAsService --replace"

        [scriptblock]::Create("$CurrentAgentFolder/config.cmd --unattended --url $DevOpsUrl --auth pat --token $PAT --pool `"$AgentPool`" --agent `"$AgentName $instance`" --acceptTeeEula --runAsService --replace").invoke()
    }
}

end {
    Stop-Transcript
}
