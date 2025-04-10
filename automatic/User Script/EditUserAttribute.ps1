<#
.SYNOPSIS
Modifies an attribute of the specified Active Directory user and sets it to a new value.

.DESCRIPTION
This script updates a specified attribute of an Active Directory user to a new value.
It requires the account name (SamAccountName), the attribute name, and the desired value.

.PARAMETER AccountName
The account name (SamAccountName) of the user whose attribute will be modified.

.PARAMETER AttributeName
The name of the attribute to modify.

.PARAMETER DesiredValue
The new value to set for the specified attribute.

.EXAMPLE
EditUserAttribute.ps1 -AccountName "john.doe" -AttributeName "Title" -DesiredValue "Manager"
#>
param (
    [bool]$NoPopup = $false,
    [string]$AccountName,
    [string]$AttributeName,
    [string]$DesiredValue
)

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the account name
if (!$NoPopup) {
    $AccountName = Get-UserInput -Message "Enter the account name (SamAccountName) of the user whose attribute will be modified (e.g., john.doe):" -Title "Account Name"
}
if (-not $AccountName) {
    Write-Host "No account name provided. Exiting..."
    exit
}

# Prompt the user for the attribute name
if (!$NoPopup) {
    $AttributeName = Get-UserInput -Message "Enter the name of the attribute to modify (e.g., Title):" -Title "Attribute Name"
}
if (-not $AttributeName) {
    Write-Host "No attribute name provided. Exiting..."
    exit
}

# Prompt the user for the desired value
if (!$NoPopup) {
    $DesiredValue = Get-UserInput -Message "Enter the new value for the attribute (e.g., Manager):" -Title "Desired Value"
}
if (-not $DesiredValue) {
    Write-Host "No desired value provided. Exiting..."
    exit
}

# Modify the user's attribute
Write-Host "Modifying attribute '$AttributeName' for user: $AccountName..."
try {
    Set-ADUser -Identity $AccountName -Replace @{$AttributeName = $DesiredValue}
    Write-Host "Attribute '$AttributeName' successfully updated to '$DesiredValue' for user: $AccountName."
} catch {
    Write-Host "Failed to modify attribute '$AttributeName' for user: $AccountName. Error: $_"
}