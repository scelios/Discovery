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
CreateNewForestDomainController.ps1
#>


param(
    [bool]$NoPopup = $false,
    [string]$DomainAddress,
    [string]$NetbiosName
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
# if (!$PSBoundParameters.ContainsKey('Subject') -or !$PSBoundParameters.ContainsKey('Marks')) {

# Prompt the user for the Domain Address
if (!$NoPopup) {
    $DomainAddress = Get-UserInput -Message "Enter the fully qualified domain name (FQDN) for the new forest (e.g., example.com):" -Title "Domain Address"
}

if (-not $DomainAddress) {
    Write-Host "No Domain Address provided. Exiting..."
    exit
}

# Prompt the user for the NetBIOS Name
if (!$NoPopup) {
    $NetbiosName = Get-UserInput -Message "Enter the NetBIOS name for the new forest (e.g., EXAMPLE):" -Title "NetBIOS Name"
}
if (-not $NetbiosName) {
    Write-Host "No NetBIOS Name provided. Exiting..."
    exit
}


# Set the IP address and DNS server for the Ethernet interface
try {
    Write-Host "Configuring IP address and DNS settings..."
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.10 -PrefixLength 24 -DefaultGateway 192.168.1.1
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.10

    # Verify the IP address and DNS settings
    Write-Host "Verifying IP address and DNS settings..."
    Get-NetIPAddress -InterfaceAlias "Ethernet"
    Get-DnsClientServerAddress -InterfaceAlias "Ethernet"
    Write-Host "IP address and DNS settings configured successfully."
} catch {
    Write-Host "An error occurred while configuring the IP address and DNS settings: $_"
    exit
}

    # Define the Safe Mode Administrator Password
    $SafeModeAdminPassword = (ConvertTo-SecureString "Test2" -AsPlainText -Force) # Replace with a secure password
Try{
    # Promote the server to a domain controller
    Write-Host "Promoting the server to a Domain Controller for the new forest..."
    Install-ADDSForest `
        -DomainName $DomainAddress `
        -DomainNetbiosName $NetbiosName `
        -SafeModeAdministratorPassword $SafeModeAdminPassword `
        -InstallDNS `
        -Force
        # Notify the user that the process is complete
    Write-Host "The server has been successfully promoted to a Domain Controller for the new forest.`nPlease restart the server to complete the installation."
} catch {
    Write-Host "An error occurred while promoting the server to a Domain Controller: $_"
}
