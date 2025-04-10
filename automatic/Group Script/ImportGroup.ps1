<#
.SYNOPSIS
Imports the members of one Active Directory group into another group.

.DESCRIPTION
This script retrieves all members of an origin group and adds them to a destination group in Active Directory.

.PARAMETER OriginGroupName
The name of the group whose members will be imported.

.PARAMETER DestinationGroupName
The name of the group to which the members will be added.

.EXAMPLE
ImportGroup.ps1
#>

param (
    [bool]$NoPopup = $false,
    [string]$OriginGroupName,
    [string]$DestinationGroupName
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
# Prompt the user for the origin group name
if (!$NoPopup) {
    $OriginGroupName = Get-UserInput -Message "Enter the name of the origin group (e.g., HR Team):" -Title "Origin Group Name"
}
if (-not $OriginGroupName) {
    Write-Host "No origin group name provided. Exiting..."
    exit
}

# Prompt the user for the destination group name
if (!$NoPopup) {
    $DestinationGroupName = Get-UserInput -Message "Enter the name of the destination group (e.g., All Employees):" -Title "Destination Group Name"
}
if (-not $DestinationGroupName) {
    Write-Host "No destination group name provided. Exiting..."
    exit
}
# Import members from one group to another
Write-Host "Importing members from group '$OriginGroupName' to group '$DestinationGroupName'..."
try {
    # Verify that the origin group exists
    $OriginGroup = Get-ADGroup -Identity $OriginGroupName -Properties Members -ErrorAction Stop
    if (-not $OriginGroup) {
        Write-Host "Origin group '$OriginGroupName' does not exist. Operation aborted."
        return
    }

    # Verify that the destination group exists
    $DestinationGroup = Get-ADGroup -Identity $DestinationGroupName -ErrorAction Stop
    if (-not $DestinationGroup) {
        Write-Host "Destination group '$DestinationGroupName' does not exist. Operation aborted."
        return
    }

    # Retrieve members of the origin group
    $OriginMembers = $OriginGroup.Members
    if (-not $OriginMembers) {
        Write-Host "Origin group '$OriginGroupName' has no members to import."
        return
    }

    # Add members to the destination group
    Add-ADGroupMember -Identity $DestinationGroupName -Members $OriginMembers
    Write-Host "Successfully imported members from '$OriginGroupName' to '$DestinationGroupName'."
} catch {
    Write-Host "Failed to import members. Error: $_"
}