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
    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

# Remove the user from the group
Write-Host "Removing user '$UserName' from group '$GroupName'..."
try {
    # Verify that the user exists
    $User = Get-ADUser -Identity $UserName -ErrorAction Stop
    if (-not $User) {
        Write-Error "User '$UserName' does not exist. Operation aborted."
        return
    }

    # Verify that the group exists
    $Group = Get-ADGroup -Identity $GroupName -ErrorAction Stop
    if (-not $Group) {
        Write-Error "Group '$GroupName' does not exist. Operation aborted."
        return
    }

    # Verify that the user is a member of the group
    $GroupMembers = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop
    if ($GroupMembers -notcontains $User.DistinguishedName) {
        Write-Error "User '$UserName' is not a member of group '$GroupName'. Operation aborted."
        return
    }

    # Remove the user from the group
    Remove-ADGroupMember -Identity $GroupName -Members $UserName -Confirm:$false
    Write-Host "User '$UserName' successfully removed from group '$GroupName'."
} catch {
    Write-Error "Failed to remove user from the group. Error: $_"
}