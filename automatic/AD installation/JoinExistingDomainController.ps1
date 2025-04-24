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
JoinExistingDomainController.ps1
#>

param (
    [bool]$NoPopup = $false,
    [string]$DomainAddress
)

Add-Type -AssemblyName Microsoft.VisualBasic

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.11 -PrefixLength 24 -DefaultGateway 192.168.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.10

# Prompt the user for the Domain Address
if (!$NoPopup) {
    $DomainAddress = Get-UserInput -Message "Enter the fully qualified domain name (FQDN) of the existing domain (e.g., example.com):" -Title "Domain Address"
}
if (-not $DomainAddress) {
    Write-Host "No Domain Address provided. Exiting..."
    exit
}

# Define the Safe Mode Administrator Password
$SafeModeAdminPassword = (ConvertTo-SecureString "Test123456789" -AsPlainText -Force) # Replace with a secure password


try {
    # Prompt the user for credentials
    Write-Host "Please provide credentials for the domain."
    $Credential = Get-Credential

    # Promote the server to a domain controller by joining the existing domain
    Write-Host "Promoting the server to a Domain Controller for the existing domain..."
    Install-ADDSDomainController `
        -DomainName $DomainAddress `
        -SafeModeAdministratorPassword $SafeModeAdminPassword `
        -Credential $Credential `
        -InstallDNS `
        -Force
} catch {
    Write-Host "An error occurred while promoting the server to a Domain Controller: $_"
    exit
}
# Notify the user that the process is complete
Write-Host "The server has been successfully promoted to a Domain Controller for the existing domain.`nPlease restart the server to complete the installation."
