Get-Disk | `
Where-Object partitionstyle -eq 'raw' | `
Initialize-Disk -PartitionStyle MBR -PassThru | `
New-Partition -UseMaximumSize -DriveLetter 'F' | `
Format-Volume -FileSystem NTFS -Confirm:$false