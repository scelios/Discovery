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

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the attributes to retrieve
$AttributesInput = Get-UserInput -Message "Enter the attributes to retrieve for all users (comma-separated, e.g., Title,Department), or leave blank to retrieve all properties:" -Title "Attributes"
if (-not $AttributesInput) {
    Write-Host "No attributes provided. Retrieving all properties..."
    $Attributes = "*"
} else {
    $Attributes = $AttributesInput -split ","
}

# Retrieve all users' information
Write-Host "Retrieving information for all users..."
try {
    $Users = Get-ADUser -Filter * -Properties $Attributes
    $Users | Select-Object SamAccountName, @($Attributes) | Format-Table -AutoSize
} catch {
    Write-Error "Failed to retrieve information for all users. Error: $_"
}