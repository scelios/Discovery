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



# Split the account name into first name and last name
$NameParts = $AccountName.Split('.')
if ($NameParts.Count -ne 2) {
    Write-Error "AccountName must be in the format 'name.surname'."
    return
}
$FirstName = $NameParts[0]
$LastName = $NameParts[1]

# Validate FirstName and LastName
if ($FirstName -match '[\\/:*?"<>|]' -or $LastName -match '[\\/:*?"<>|]') {
    Write-Error "FirstName or LastName contains invalid characters. Please use valid characters."
    exit
}

# Trim spaces from FirstName and LastName
$FirstName = $FirstName.Trim()
$LastName = $LastName.Trim()

# Construct the email address and UserPrincipalName
$DomainName = "example.com" # Replace with your actual domain name
$EmailAddress = "$AccountName@$DomainName"
$UserPrincipalName = $EmailAddress

# Securely define the default password
$DefaultPassword = ConvertTo-SecureString "TotalyN0tSecure" -AsPlainText -Force

# Check if the user already exists
if (Get-ADUser -Filter { SamAccountName -eq $AccountName }) {
    Write-Host "User $AccountName already exists. Exiting..."
    exit
}

# Prompt the user for the organizational unit
$OUname = Get-UserInput -Message "Enter the distinguished name (DN) of the Organizational Unit (OU) where the user will be created (e.g., OU=Users,DC=example,DC=com):" -Title "Organizational Unit"
if (-not $OUname) {
    Write-Host "No organizational unit provided. Exiting..."
    exit
}

# Construct the full DN for the OU
$DomainDN = "DC=example,DC=com" # Replace with your actual domain DN
$OrganisationUnit = "OU=$OUname,$DomainDN"

# Check if the OU exists
if (-not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OrganisationUnit })) {
    # Validate the OrganisationUnit DN
    if ($OrganisationUnit -match '[\\/:*?"<>|]') {
        Write-Error "The group name '$OrganisationUnit' contains invalid characters. Please use a valid name."
        exit
    }

    # Create the OU if it doesn't exist
    try {
        Write-Host "Organizational Unit $OrganisationUnit does not exist. Creating it..."
        New-ADOrganizationalUnit -Name $OUname -Path "DC=example,DC=com" # Replace with your actual domain
    } catch {
        Write-Error "Failed to create Organizational Unit $OUname. Error: $_"
        exit
    }
    Write-Host "Organizational Unit $OUname created successfully."
}

# Prompt the user for the desired group
$DesiredGroup = Get-UserInput -Message "Enter the name of the group to which the user will be added (e.g., IT):" -Title "Desired Group"
if (-not $DesiredGroup) {
    Write-Host "No group name provided. Exiting..."
    exit
}
# Check if the group exists
if (-not (Get-ADGroup -Filter { Name -eq $DesiredGroup })) {
    # Validate the OrganisationUnit DN
    if (-not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OrganisationUnit })) {
        Write-Error "The specified Organizational Unit (OU) path '$OrganisationUnit' is invalid. Please provide a valid DN."
        exit
    }

    # Validate the DesiredGroup name
    if ($DesiredGroup -match '[\\/:*?"<>|]') {
        Write-Error "The group name '$DesiredGroup' contains invalid characters. Please use a valid name."
        exit
    }

    # Create the group if it doesn't exist
    Write-Host "Group $DesiredGroup does not exist. Creating it..."
    try {
        # Create the group with default parameters
        New-ADGroup -Name $DesiredGroup -Path $OrganisationUnit -GroupScope Global -GroupCategory Security
    } catch {
        Write-Error "Failed to create group $DesiredGroup. Error: $_"
        exit
    }
    Write-Host "Group $DesiredGroup created successfully."
}
try {
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
} catch {
    Write-Error "Failed to create user or add to group. Error: $_"
}