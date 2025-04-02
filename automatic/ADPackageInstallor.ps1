# This script installs the Active Directory Domain Services (AD DS) role
# and promotes the server to a domain controller.

# Import the ServerManager module to manage Windows features
Import-Module ServerManager

# Install the Active Directory Domain Services role and its dependencies
Write-Host "Installing Active Directory Domain Services (AD DS) role..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

# Import the ADDSDeployment module to configure the domain controller
Write-Host "Importing ADDSDeployment module..."
Import-Module ADDSDeployment

# Define the domain name and other configuration parameters
$DomainName = "example.com" # Replace with your desired domain name
$SafeModeAdminPassword = (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) # Replace with a secure password

# Promote the server to a domain controller
Write-Host "Promoting the server to a domain controller..."
Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -InstallDNS `
    -Force

# Notify the user that the process is complete
Write-Host "Active Directory Domain Services installation and configuration complete."-----