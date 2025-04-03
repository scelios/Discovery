<#
.SYNOPSIS
Changes the server's IP address and DNS settings to match an existing domain.


.PARAMETER IPAddress
The fully qualified domain ip address (FQDN) of the existing domain (e.g., example.com).
.EXAMPLE
Join-ExistingDomainController.ps1 -IPAddress "192.168.1.10"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$IPAddress
)

# Resolve the IP address of the domain
Write-Host "Resolving the IP address of the domain: $IPAddress..."
$DomainIP = [System.Net.Dns]::GetHostAddresses($IPAddress) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
if (-not $DomainIP) {
    Write-Error "Failed to resolve the IP address of the domain: $IPAddress"
    return
}
Write-Host "Domain IP address resolved: $DomainIP"

# Increment the last octet of the domain's IP address by 1
$IPParts = $DomainIP.ToString().Split('.')
$IPParts[3] = [int]$IPParts[3] + 1 % 256 # Ensure it wraps around if it exceeds 255
if ($IPParts[3] -eq 0) {
    Write-Error "The last octet of the IP address cannot be 0. Please choose a different domain."
    return
}
$ServerIP = $IPParts -join '.'
$SubnetMask = "255.255.255.0" # Default subnet mask (adjust if needed)

# Configure the server's IP address and DNS settings
Write-Host "Configuring the server's IP address and DNS settings..."
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ServerIP -PrefixLength 24 -DefaultGateway $DomainIP
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DomainIP
Write-Host "Server IP address set to: $ServerIP"
Write-Host "Preferred DNS server set to: $DomainIP"