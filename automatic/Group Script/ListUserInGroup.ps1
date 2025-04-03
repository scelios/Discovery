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

Add-Type -AssemblyName Microsoft.VisualBasic

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the group name
$GroupName = Get-UserInput -Message "Enter the name of the group whose members you want to list (e.g., HR Team):" -Title "Group Name"
if (-not $GroupName) {
    Write-Host "No group name provided. Exiting..."
    exit
}

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