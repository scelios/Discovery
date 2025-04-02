<#
.SYNOPSIS
Retrieves information about all Active Directory users.

.DESCRIPTION
This script retrieves specific attributes of all Active Directory users based on the provided attribute filter.

.PARAMETER Attributes
The attributes to retrieve for all users.

.EXAMPLE
ReadDataBaseInformation.ps1 -Attributes "Title", "Department"
#>

param (
    [Parameter(Mandatory = $true)]
    [string[]]$Attributes
)

# Retrieve all users' information
Write-Host "Retrieving information for all users..."
try {
    $Users = Get-ADUser -Filter * -Properties $Attributes
    $Users | Select-Object SamAccountName, @($Attributes) | Format-Table -AutoSize
} catch {
    Write-Error "Failed to retrieve information for all users. Error: $_"
}