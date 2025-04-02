<#
.SYNOPSIS
Edits an Active Directory group by modifying one attribute to a desired value.

.DESCRIPTION
This script modifies a specified attribute of an Active Directory group to a new value.

.PARAMETER GroupName
The name of the group to modify.

.PARAMETER Attribute
The attribute of the group to edit.

.PARAMETER NewValue
The new value to set for the specified attribute.

.EXAMPLE
ModifyGroup.ps1 -GroupName "HR Team" -Attribute "Description" -NewValue "Updated description for HR team"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$Attribute,

    [Parameter(Mandatory = $true)]
    [string]$NewValue
)

# Modify the group attribute
Write-Host "Modifying group '$GroupName'..."
try {
    Set-ADGroup -Identity $GroupName -Replace @{$Attribute = $NewValue}
    Write-Host "Group '$GroupName' updated successfully. Attribute '$Attribute' set to '$NewValue'."
} catch {
    Write-Error "Failed to modify the group. Error: $_"
}