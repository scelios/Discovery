<#
.SYNOPSIS
Adds a user to a specified Active Directory group.

.DESCRIPTION
This script adds a user to a specified Active Directory group. It verifies that the user exists before attempting to add them to the group.

.PARAMETER UserName
The name (SamAccountName) of the user to add to the group.

.PARAMETER GroupName
The name of the group to which the user will be added.

.EXAMPLE
AddUserToGroup.ps1 -UserName "jdoe" -GroupName "HR Team"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

# Add the user to the group
Write-Host "Adding user '$UserName' to group '$GroupName'..."
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

    # Add the user to the group
    Add-ADGroupMember -Identity $GroupName -Members $UserName
    Write-Host "User '$UserName' successfully added to group '$GroupName'."
} catch {
    Write-Error "Failed to add user to the group. Error: $_"
}