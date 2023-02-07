Param(
    [Parameter(Mandatory=$true)]
    [string] $DomainName,
    [Parameter(Mandatory=$true)]
    [string] $SiteName,
    [Parameter(Mandatory=$true)]
    [string] $UserName,
    [Parameter(Mandatory=$true)]
    [string] $Password
)

# Prepare existing domain admin credential
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$UserName@$DomainName", (ConvertTo-SecureString -String $Password -AsPlainText -Force)

# Install AD Domain Services Role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Initialize VM data disk for NTDS
$DataVolume = Get-Disk | `
    Where-Object -Property PartitionStyle -eq 'raw' | `
    Select-Object -Last 1 | `
    Initialize-Disk -PartitionStyle GPT -PassThru | `
    New-Partition -AssignDriveLetter -UseMaximumSize | `
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "NTDS_Data" -Confirm:$false

# Create AD domain controller in existing forest and domain
Install-ADDSDomainController -DomainName $DomainName -SiteName $SiteName `
    -InstallDNS `
    -Credential $DomainCredential `
    -DatabasePath "$($DataVolume.DriveLetter):\NTDS" `
    -SysvolPath "$($DataVolume.DriveLetter):\SYSVOL" `
    -LogPath "$($DataVolume.DriveLetter):\Logs" `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) `
    -Force
