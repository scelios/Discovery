<#
.SYNOPSIS
Retrieves user information from the Active Directory server.

.DESCRIPTION
This script retrieves information about a specified Active Directory user. 
The user can specify the account name (SamAccountName) and optionally filter the attributes to retrieve.

.PARAMETER AccountName
The account name (SamAccountName) of the user whose information will be retrieved.

.PARAMETER Attributes
An optional list of attributes to retrieve. If not specified, all attributes will be retrieved.

.EXAMPLE
ReadUserInformation.ps1 -AccountName "john.doe" -Attributes "Title", "Department"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName,

    [Parameter(Mandatory = $false)]
    [string[]]$Attributes
)

# Retrieve user information
Write-Host "Retrieving information for user: $AccountName..."
try {
    if ($Attributes) {
        # Retrieve only the specified attributes
        $UserInfo = Get-ADUser -Identity $AccountName -Properties $Attributes
        Write-Host "Retrieved the following attributes for user $AccountName:"
        $UserInfo | Select-Object SamAccountName, $Attributes | Format-Table -AutoSize
    } else {
        # Retrieve all attributes
        $UserInfo = Get-ADUser -Identity $AccountName -Properties *
        Write-Host "Retrieved all attributes for user $AccountName:"
        $UserInfo | Format-List
    }
} catch {
    Write-Error "Failed to retrieve information for user: $Account# filepath: /home/hall/Discovery/automatic/User Script/ReadUserInformation.ps1

