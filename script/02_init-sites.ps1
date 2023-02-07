Param(
    [Parameter(Mandatory=$true)]
    [string] $DomainName,
    [Parameter(Mandatory=$true)]
    [string] $Site1Name,
    [Parameter(Mandatory=$true)]
    [string] $Site1CidrBlock,
    [Parameter(Mandatory=$true)]
    [string] $Site2Name,
    [Parameter(Mandatory=$true)]
    [string] $Site2CidrBlock,
    [Parameter(Mandatory=$true)]
    [string] $UserName,
    [Parameter(Mandatory=$true)]
    [string] $Password
)

# Prepare existing domain admin credential
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$UserName@$DomainName", (ConvertTo-SecureString -String $Password -AsPlainText -Force)

# Install AD Domain Services Role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Rename first AD site to match lab site 1
Get-ADReplicationSite -Identity "Default-First-Site-Name" `
    -Server $DomainName -Credential $DomainCredential | `
    Rename-ADObject -NewName $Site1Name `
    -Server $DomainName -Credential $DomainCredential 

# Create Subnet address space for lab site 1
New-AdReplicationSubnet -Name $Site1CidrBlock --Site $Site1Name -Server $DomainName -Credential $DomainCredential

# Create AD site for lab site 2
New-AdReplicationSite -Name $Site2Name -Server $DomainName -Credential $DomainCredential

# Create Subnet address space for lab site 2
New-AdReplicationSubnet -Name $Site2CidrBlock -Site $Site2Name -Server $DomainName -Credential $DomainCredential
