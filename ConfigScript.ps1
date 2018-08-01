Write-Output "Configuring environment Environment vars"
[Environment]::SetEnvironmentVariable("JAVA_HOME", "c:\\jre1.8.0_91", "Machine")

[Environment]::SetEnvironmentVariable("JENKINS_HOME", "c:\\jenkins", "Machine")


Write-Output "Downloading jre"
(new-object System.Net.WebClient).Downloadfile('http://javadl.oracle.com/webapps/download/AutoDL?BundleId=210185', 'C:\jre-8u91-windows-x64.exe')

Write-Output "Installing jre"
start-process -filepath C:\\jre-8u91-windows-x64.exe -passthru -wait -argumentlist "/s INSTALLDIR=$env:JAVA_HOME /L install64.log"

Write-Output "Removing jre"
del C:\jre-8u91-windows-x64.exe

Write-Output "Configuring environment Environment vars"
$env:PATH = $env:JAVA_HOME + '\\bin;' + $env:PATH
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, "Machine")
mkdir $env:JENKINS_HOME

Write-Output "Generalizing VM"
& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit
while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }