Param(
    [Parameter(Mandatory=$true)]
    [string] $DomainName,
    [Parameter(Mandatory=$true)]
    [string] $SafeModeAdministratorPassword
)

# Initialize VM data disk for NTDS
$DataVolume = Get-Disk | `
    Where-Object -Property PartitionStyle -eq 'raw' | `
    Select-Object -Last 1 | `
    Initialize-Disk -PartitionStyle GPT -PassThru | `
    New-Partition -AssignDriveLetter -UseMaximumSize | `
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "NTDS_Data" -Confirm:$false

# Install AD Domain Services Role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Create First AD domain controller
Install-ADDSForest -DomainName $DomainName `
    -InstallDNS `
    -DomainMode WinThreshold `
    -ForestMode WinThreshold `
    -DatabasePath "$($DataVolume.DriveLetter):\NTDS" `
    -SysvolPath "$($DataVolume.DriveLetter):\SYSVOL" `
    -LogPath "$($DataVolume.DriveLetter):\Logs" `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String $SafeModeAdministratorPassword -AsPlainText -Force)`
    -Force -Debug

Start-Sleep -Seconds 300
