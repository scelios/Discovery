<#
.SYNOPSIS
Adds a user to a specified Active Directory group.

.DESCRIPTION
This script adds a user to a specified Active Directory group. It verifies that the user exists before attempting to add them to the group.

.EXAMPLE
AddUserToGroup.ps1
#>
param (
    [bool]$NoPopup = $false,
    [string]$UserName,
    [string]$GroupName
)

Add-Type -AssemblyName Microsoft.VisualBasic

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the username
if (!$NoPopup) {
    $UserName = Get-UserInput -Message "Enter the username (SamAccountName) of the user to add to the group (e.g., jdoe):" -Title "User Name"
}
if (-not $UserName) {
    Write-Host "No username provided. Exiting..."
    exit
}

# Prompt the user for the group name
if (!$NoPopup) {
    $GroupName = Get-UserInput -Message "Enter the name of the group to which the user will be added (e.g., HR Team):" -Title "Group Name"
}
if (-not $GroupName) {
    Write-Host "No group name provided. Exiting..."
    exit
}

# Add the user to the group
Write-Host "Adding user '$UserName' to group '$GroupName'..."
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
    Write-Host "Group '$GroupName' exists."
    # Add the user to the group
    Add-ADGroupMember -Identity $GroupName -Members $UserName
    Write-Host "User '$UserName' successfully added to group '$GroupName'."
} catch {
    Write-Host "Failed to add user to the group. Error: $_"
}