Param(
    [Parameter(Mandatory=$true)]
    [string] $DomainName,
    [Parameter(Mandatory=$true)]
    [string] $SafeModeAdministratorPassword
)

# Install AD Domain Services Role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Initialize VM data disk for NTDS
$DataVolume = Get-Disk | `
    Where-Object -Property PartitionStyle -eq 'raw' | `
    Select-Object -Last 1 | `
    Initialize-Disk -PartitionStyle GPT -PassThru | `
    New-Partition -AssignDriveLetter -UseMaximumSize | `
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "NTDS_Data" -Confirm:$false

# Create First AD domain controller in new forest and domain
Install-ADDSForest -DomainName $DomainName `
    -InstallDNS `
    -DomainMode WinThreshold `
    -ForestMode WinThreshold `
    -DatabasePath "$($DataVolume.DriveLetter):\NTDS" `
    -SysvolPath "$($DataVolume.DriveLetter):\SYSVOL" `
    -LogPath "$($DataVolume.DriveLetter):\Logs" `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String $SafeModeAdministratorPassword -AsPlainText -Force) `
    -Force
