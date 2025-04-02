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
ImportGroup.ps1 -OriginGroupName "HR Team" -DestinationGroupName "All Employees"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$OriginGroupName,

    [Parameter(Mandatory = $true)]
    [string]$DestinationGroupName
)

# Import members from one group to another
Write-Host "Importing members from group '$OriginGroupName' to group '$DestinationGroupName'..."
try {
    # Verify that the origin group exists
    $OriginGroup = Get-ADGroup -Identity $OriginGroupName -Properties Members -ErrorAction Stop
    if (-not $OriginGroup) {
        Write-Error "Origin group '$OriginGroupName' does not exist. Operation aborted."
        return
    }

    # Verify that the destination group exists
    $DestinationGroup = Get-ADGroup -Identity $DestinationGroupName -ErrorAction Stop
    if (-not $DestinationGroup) {
        Write-Error "Destination group '$DestinationGroupName' does not exist. Operation aborted."
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
    Write-Error "Failed to import members. Error: $_"
}