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

if (-not $PropertyName) {
    Write-Host "No property name provided. Retrieving all properties for each group."
} else {
    Write-Host "Retrieving property '$PropertyName' for each group."
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
        if (-not $PropertyName -or $PropertyName -eq "*") {
            # If no specific property is provided, print all properties
            foreach ($Property in $Group.PSObject.Properties) {
                Write-Host "Group: $($Group.Name), Property '$($Property.Name)': $($Property.Value)"
            }
        } else {
            # If a specific property is provided, check and print it
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