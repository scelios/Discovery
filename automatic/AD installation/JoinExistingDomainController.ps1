function Join-ExistingDomainController {
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
    Join-ExistingDomainController -DomainAddress "example.com"
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$DomainAddress
    )

    # Resolve the IP address of the domain
    Write-Host "Resolving the IP address of the domain: $DomainAddress..."
    $DomainIP = [System.Net.Dns]::GetHostAddresses($DomainAddress) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
    if (-not $DomainIP) {
        Write-Error "Failed to resolve the IP address of the domain: $DomainAddress"
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
}