<#
.SYNOPSIS
Creates a new Active Directory user with specified parameters.

.DESCRIPTION
This script creates a new Active Directory user with the following assumptions:
- Email address: name.surname@domainName.com
- Default password: Securely stored and requires change at first login.
- UserPrincipalName: Same as the email address.

.PARAMETER AccountName
The account name in the format "name.surname".

.PARAMETER OrganisationUnit
The distinguished name (DN) of the Organizational Unit (OU) where the user will be created.

.PARAMETER DesiredGroup
The name of the group to which the user will be added.

.EXAMPLE
UserCreation.ps1 -AccountName "john.doe" -OrganisationUnit "OU=Users,DC=example,DC=com" -DesiredGroup "IT"
#>



function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the account name
$AccountName = Get-UserInput -Message "Enter the account name in the format 'name.surname' (e.g., john.doe):" -Title "Account Name"
if (-not $AccountName) {
    Write-Host "No account name provided. Exiting..."
    exit
}

# Prompt the user for the organizational unit
$OrganisationUnit = Get-UserInput -Message "Enter the distinguished name (DN) of the Organizational Unit (OU) where the user will be created (e.g., OU=Users,DC=example,DC=com):" -Title "Organizational Unit"
if (-not $OrganisationUnit) {
    Write-Host "No organizational unit provided. Exiting..."
    exit
}

# Prompt the user for the desired group
$DesiredGroup = Get-UserInput -Message "Enter the name of the group to which the user will be added (e.g., IT):" -Title "Desired Group"
if (-not $DesiredGroup) {
    Write-Host "No group name provided. Exiting..."
    exit
}

# Split the account name into first name and last name
$NameParts = $AccountName.Split('.')
if ($NameParts.Count -ne 2) {
    Write-Error "AccountName must be in the format 'name.surname'."
    return
}
$FirstName = $NameParts[0]
$LastName = $NameParts[1]

# Construct the email address and UserPrincipalName
$DomainName = "example.com" # Replace with your actual domain name
$EmailAddress = "$AccountName@$DomainName"
$UserPrincipalName = $EmailAddress

# Securely define the default password
$DefaultPassword = ConvertTo-SecureString "TotalyN0tSecure" -AsPlainText -Force

# Create the new user
Write-Host "Creating user: $AccountName in OU: $OrganisationUnit..."
New-ADUser `
    -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $AccountName `
    -UserPrincipalName $UserPrincipalName `
    -EmailAddress $EmailAddress `
    -Path $OrganisationUnit `
    -AccountPassword $DefaultPassword `
    -ChangePasswordAtLogon $true `
    -Enabled $true

Write-Host "User $AccountName created successfully."

# Add the user to the desired group
Write-Host "Adding user $AccountName to group: $DesiredGroup..."
Add-ADGroupMember -Identity $DesiredGroup -Members $AccountName
Write-Host "User $AccountName added to group $DesiredGroup successfully."