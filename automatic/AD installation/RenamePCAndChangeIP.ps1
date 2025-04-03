<#
.SYNOPSIS
Changes the server's Name and IP address to match an existing domain.


.PARAMETER Name
The new name for the server (e.g., NewServerName).
.PARAMETER ServerIP
The new IPAdress of the server.
.PARAMETER DomainIP
New preferred Dns of the server.

.EXAMPLE
RenamePCAndChangeIP.ps1 -Name "NewserverName" -ServerIP "192.168.1.11" -DomainIP "192.168.1.10"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$ServerIP,

    [Parameter(Mandatory = $true)]
    [string]$DomainIP
)

# Check if the server name is already set
$currentName = (Get-ComputerInfo).CsName
if ($currentName -eq $Name) {
    Write-Host "The server name is already set to: $Name"
} else {
    # Set the new name for the server
    Rename-Computer -NewName $Name -Force
    Write-Host "The server has been successfully renamed to: $Name"
}

# Configure the server's IP address and DNS settings
Write-Host "Configuring the server's IP address and DNS settings..."

# Check if the IP address already exists
$existingIP = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq $ServerIP }

if ($existingIP) {
    Write-Host "The IP address $ServerIP already exists. Updating settings..."
    Set-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ServerIP -PrefixLength 24 -DefaultGateway $DomainIP
} else {
    Write-Host "Adding the new IP address $ServerIP..."
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ServerIP -PrefixLength 24 -DefaultGateway $DomainIP
}

# Check if the DNS server is already configured
$currentDNS = (Get-DnsClientServerAddress -InterfaceAlias "Ethernet").ServerAddresses
if ($currentDNS -contains $DomainIP) {
    Write-Host "The DNS server is already set to: $DomainIP"
} else {
    Write-Host "Configuring the DNS server to: $DomainIP"
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DomainIP
}

Write-Host "The server's IP address is set to: $ServerIP"
Write-Host "The preferred DNS server is set to: $DomainIP"