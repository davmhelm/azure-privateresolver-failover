Param(
    [Parameter(Mandatory=$true)]
    [string] $DomainName,
    [string] $ForwarderIpAddresses
)

# Convert the comma-separated string input into a PowerShell array
$IpAddressArray = $ForwarderIpAddresses -split ","

# Forwarder timeout must be lower than client's DNS query timeout, in order for 
# the forwarding server to have a chance at receiving a response from DNS servers 2..n and
# forwarding that response back to the client
# Windows client default behavior for 1 configured DNS server:
# https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/dns-client-resolution-timeouts#what-is-the-default-behavior-of-a-dns-client-when-a-single-dns-server-is-configured-on-the-nic
# Windows client default behavior for 2 configured DNS servers:
# https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/dns-client-resolution-timeouts#what-is-the-default-behavior-of-a-windows-7-or-windows-8-dns-client-when-two-dns-servers-are-configured-on-the-nic
Add-DnsServerConditionalForwarderZone -Name "$DomainName." -MasterServers $IpAddressArray -ForwarderTimeout 2 -PassThru
