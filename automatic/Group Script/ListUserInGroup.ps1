<#
.SYNOPSIS
Retrieves an exhaustive list of users in a specified Active Directory group.

.DESCRIPTION
This script retrieves all users who are members of a specified Active Directory group.

.PARAMETER GroupName
The name of the group whose members will be listed.

.EXAMPLE
ListUserInGroup.ps1 -GroupName "HR Team"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

# Retrieve the list of users in the group
Write-Host "Retrieving members of group '$GroupName'..."
try {
    $Group = Get-ADGroup -Identity $GroupName -Properties Members
    if ($Group.Members) {
        $Group.Members | ForEach-Object { Get-ADUser -Identity $_ } | 
        Select-Object SamAccountName, Name, EmailAddress | 
        Format-Table -AutoSize
    } else {
        Write-Host "The group '$GroupName' has no members."
    }
} catch {
    Write-Error "Failed to retrieve members of the group. Error: $_"
}