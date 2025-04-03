<#
.SYNOPSIS
Promotes a server to a Domain Controller by creating a new forest.

.DESCRIPTION
This function promotes the server to a Domain Controller by creating a new forest.

.PARAMETER DomainAddress
The fully qualified domain name (FQDN) for the new forest (e.g., example.com).

.PARAMETER NetbiosName
The NetBIOS name for the new forest (e.g., EXAMPLE).

.EXAMPLE
CreateNewForestDomainController.ps1 -DomainAddress "example.com" -NetbiosName "EXAMPLE"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainAddress,

    [Parameter(Mandatory = $true)]
    [string]$NetbiosName
)


# Set the IP address and DNS server for the Ethernet interface
Write-Host "Configuring IP address and DNS settings..."
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.10 -PrefixLength 24 -DefaultGateway 192.168.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.10

# Verify the IP address and DNS settings
Write-Host "Verifying IP address and DNS settings..."
Get-NetIPAddress -InterfaceAlias "Ethernet"
Get-DnsClientServerAddress -InterfaceAlias "Ethernet"
Write-Host "IP address and DNS settings configured successfully."

# Define the Safe Mode Administrator Password
$SafeModeAdminPassword = (ConvertTo-SecureString "Test2" -AsPlainText -Force) # Replace with a secure password

# Promote the server to a domain controller
Write-Host "Promoting the server to a Domain Controller for the new forest..."
Install-ADDSForest `
    -DomainName $DomainAddress `
    -DomainNetbiosName $NetbiosName `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -InstallDNS `
    -Force

# Notify the user that the process is complete
Write-Host "The server has been successfully promoted to a Domain Controller for the new forest."
