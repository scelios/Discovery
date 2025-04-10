<#
.SYNOPSIS
Changes the server's Name and IP address to match an existing domain.

.DESCRIPTION
This script renames the server and configures its IP address and DNS settings.

.EXAMPLE
RenamePCAndChangeIP.ps1
#>
param (
    [bool]$NoPopup = $false,
    [string]$Name,
    [string]$ServerIP,
    [string]$DomainIP
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

# Prompt the user for the new server name
if (!$NoPopup) {
    $Name = Get-UserInput -Message "Enter the new name for the server (e.g., NewServerName):" -Title "Server Name"
}
if (-not $Name) {
    Write-Host "No server name provided. Exiting..."
    exit
}

# Prompt the user for the new server IP address
if (!$NoPopup) {
    $ServerIP = Get-UserInput -Message "Enter the new IP address for the server (e.g., 192.168.1.11):" -Title "Server IP Address"
}
if (-not $ServerIP) {
    Write-Host "No server IP address provided. Exiting..."
    exit
}

# Prompt the user for the preferred DNS server IP address
if (!$NoPopup) {
    
}
$DomainIP = Get-UserInput -Message "Enter the preferred DNS server IP address (e.g., 192.168.1.10):" -Title "DNS Server IP Address"
if (-not $DomainIP) {
    Write-Host "No DNS server IP address provided. Exiting..."
    exit
}

try {
    # Check if the server name is already set
    $currentName = (Get-ComputerInfo).CsName
    if ($currentName -eq $Name) {
        Write-Host "The server name is already set to: $Name"
    } else {
        # Set the new name for the server
        Rename-Computer -NewName $Name -Force
        Write-Host "The server has been successfully renamed to: $Name"
    }
}catch {
        Write-Host "An error occurred while renaming the server: $_"
        exit
}

# Configure the server's IP address and DNS settings
Write-Host "Configuring the server's IP address and DNS settings..."

# Check if the IP address already exists
$existingIP = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 | Where-Object { $_.IPAddress -eq $ServerIP }

try {
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
} catch {
    Write-Host "An error occurred while configuring the IP address and DNS settings: $_"
    exit
}
Write-Host "The server's IP address is set to: $ServerIP"
Write-Host "The preferred DNS server is set to: $DomainIP"

# Notify the user that the process is complete
Write-Host "The server has been successfully renamed and its IP address and DNS settings have been configured."
Write-Host "Please restart the server to apply the changes."