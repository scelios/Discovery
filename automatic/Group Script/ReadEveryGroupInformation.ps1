<#
.SYNOPSIS
Retrieves information from every group in the domain.

.DESCRIPTION
This script retrieves information from every group in the domain. If no property name is provided, it retrieves all properties for each group.

.PARAMETER PropertyName
(Optional) The specific property to retrieve for each group. If not provided, all properties will be retrieved.

.EXAMPLE
ReadEveryGroupInformation.ps1

.EXAMPLE
ReadEveryGroupInformation.ps1 -PropertyName "Description"
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$PropertyName
)

# Retrieve information for all groups
Write-Host "Retrieving information for all groups in the domain..."
try {
    # Get all groups
    $Groups = Get-ADGroup -Filter * -Properties *

    if ($null -eq $Groups) {
        Write-Host "No groups found in the domain."
        return
    }

    # Retrieve specific property or all properties for each group
    foreach ($Group in $Groups) {
        if ($PropertyName) {
            if ($Group.PSObject.Properties[$PropertyName]) {
                Write-Host "Group: $($Group.Name), Property '$PropertyName': $($Group.$PropertyName)"
            } else {
                Write-Host "Group: $($Group.Name), Property '$PropertyName' does not exist."
            }
        } else {
            Write-Host "All properties for group: $($Group.Name)"
            $Group | Format-List
        }
    }
} catch {
    Write-Error "Failed to retrieve information for all groups. Error: $_"
}