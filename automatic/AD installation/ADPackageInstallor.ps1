# This script installs the Active Directory Domain Services (AD DS) role

# Import the ServerManager module to manage Windows features
Import-Module ServerManager

# Install the Active Directory Domain Services role and its dependencies
Write-Host "Installing Active Directory Domain Services (AD DS) role..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

# Import the ADDSDeployment module to configure the domain controller
Write-Host "Importing ADDSDeployment module..."
Import-Module ADDSDeployment


# Notify the user that the process is complete
Write-Host "Active Directory Domain Services installation and configuration complete."-----