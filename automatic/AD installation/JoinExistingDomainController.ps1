<#
.SYNOPSIS
Promotes a server to a Domain Controller by joining an existing domain.

.DESCRIPTION
This function installs the Active Directory Domain Services (AD DS) role
and promotes the server to a Domain Controller by joining an already existing domain.
It also configures the server's IP address and DNS settings based on the domain's IP.

.PARAMETER DomainAddress
The fully qualified domain name (FQDN) of the existing domain (e.g., example.com).

.EXAMPLE
Join-ExistingDomainController.ps1 -DomainAddress "example.com"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainAddress
)


# Define the Safe Mode Administrator Password
$SafeModeAdminPassword = (ConvertTo-SecureString "Test2" -AsPlainText -Force) # Replace with a secure password

# Promote the server to a domain controller by joining the existing domain
Write-Host "Promoting the server to a Domain Controller for the existing domain..."
Install-ADDSDomainController `
    -DomainName $DomainAddress `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -InstallDNS `
    -Force

# Notify the user that the process is complete
Write-Host "The server has been successfully promoted to a Domain Controller for the existing domain."
