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
ReadEveryGroupInformation.ps1
#>
param (
    [bool]$NoPopup = $false,
    [string]$PropertyName
)

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the property name (optional)
if (!$NoPopup) {
    $PropertyName = Get-UserInput -Message "Enter the property name to retrieve for each group (e.g., Description), or leave blank to retrieve all properties:" -Title "Property Name"
}

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
        }
    }
} catch {
    Write-Host "Failed to retrieve information for all groups. Error: $_"
}