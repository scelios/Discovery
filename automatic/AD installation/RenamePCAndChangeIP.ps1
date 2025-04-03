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

# Set the new name for the server
Rename-Computer -NewName $Name -Force
Write-Host "Server renamed successfully to: $Name"

# Configure the server's IP address and DNS settings
Write-Host "Configuring the server's IP address and DNS settings..."
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ServerIP -PrefixLength 24 -DefaultGateway $DomainIP
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DomainIP



Write-Host "Server IP address set to: $ServerIP"
Write-Host "Preferred DNS server set to: $DomainIP"

# Restart the server to apply the changes
Write-Host "Restarting the server to apply the changes..."
Restart-Computer -Force
Write-Host "Server will restart now."