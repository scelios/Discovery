<#
.SYNOPSIS
Removes a user from a specified Active Directory group.

.DESCRIPTION
This script removes a user from a specified Active Directory group. It verifies that the user exists and is a member of the group before attempting the removal.

.PARAMETER UserName
The name (SamAccountName) of the user to remove from the group.

.PARAMETER GroupName
The name of the group from which the user will be removed.

.EXAMPLE
RemoveUserToGroup.ps1 -UserName "jdoe" -GroupName "HR Team"
#>
param (
    [bool]$NoPopup = $false,
    [string]$UserName,
    [string]$GroupName
)

Add-Type -AssemblyName Microsoft.VisualBasic

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the username
if (!$NoPopup) {
    $UserName = Get-UserInput -Message "Enter the username (SamAccountName) of the user to remove from the group (e.g., jdoe):" -Title "User Name"
}
if (-not $UserName) {
    Write-Host "No username provided. Exiting..."
    exit
}

# Prompt the user for the group name
if (!$NoPopup) {
    $GroupName = Get-UserInput -Message "Enter the name of the group from which the user will be removed (e.g., HR Team):" -Title "Group Name"
}
if (-not $GroupName) {
    Write-Host "No group name provided. Exiting..."
    exit
}

# Remove the user from the group
Write-Host "Removing user '$UserName' from group '$GroupName'..."
try {
    # Verify that the user exists
    $User = Get-ADUser -Filter "SamAccountName -eq '$($UserName)'" -ErrorAction Stop
    if (-not $User) {
        Write-Host "User $($UserName) does not exists."
        return
    }

    # Verify that the group exists
    $Group = Get-ADGroup -Filter "Name -eq '$($GroupName)'" -ErrorAction Stop
    if (-not $Group) {
        Write-Host "Group $($GroupName) does not exists."
        return
    }

    # Verify that the user is a member of the group
    $GroupMembers = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop | Select-Object -ExpandProperty SamAccountName

    if ($UserName -notin $GroupMembers) {
        Write-Host "User '$UserName' is not a member of group '$GroupName'. Operation aborted."
        return
    }

    # Remove the user from the group
    Remove-ADGroupMember -Identity $GroupName -Members $UserName -Confirm:$false
    Write-Host "User '$UserName' successfully removed from group '$GroupName'."
} catch {
    Write-Host "Failed to remove user from the group. Error: $_"
}