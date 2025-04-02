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
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $true)]
    [string]$AttributeName,

    [Parameter(Mandatory = $true)]
    [string]$DesiredValue
)

# Modify the user's attribute
Write-Host "Modifying attribute '$AttributeName' for user: $AccountName..."
try {
    Set-ADUser -Identity $AccountName -Replace @{$AttributeName = $DesiredValue}
    Write-Host "Attribute '$AttributeName' successfully updated to '$DesiredValue' for user: $AccountName."
} catch {
    Write-Error "Failed to modify attribute '$AttributeName' for user: $AccountName. Error: $_"
}