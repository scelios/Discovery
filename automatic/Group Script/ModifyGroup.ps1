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
ModifyGroup.ps1
#>
param (
    [bool]$NoPopup = $false,
    [string]$GroupName,
    [string]$Attribute,
    [string]$NewValue
)

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the group name
if (!$NoPopup) {
    $GroupName = Get-UserInput -Message "Enter the name of the group to modify (e.g., HR Team):" -Title "Group Name"
}
if (-not $GroupName) {
    Write-Host "No group name provided. Exiting..."
    exit
}

# Prompt the user for the attribute to modify
if (!$NoPopup) {
    $Attribute = Get-UserInput -Message "Enter the attribute of the group to modify (e.g., Description):" -Title "Group Attribute"
}
if (-not $Attribute) {
    Write-Host "No attribute provided. Exiting..."
    exit
}
# List of modifiable attributes
# $ModifiableAttributes = @("Description", "ManagedBy", "DisplayName")

# Check if the attribute is modifiable
# if ($Attribute -notin $ModifiableAttributes) {
#     Write-Host "The attribute '$Attribute' cannot be modified. Please choose a valid attribute (e.g., Description, ManagedBy, DisplayName)."
#     exit
# }

# Prompt the user for the new value of the attribute
if (!$NoPopup) {
    $NewValue = Get-UserInput -Message "Enter the new value for the attribute (e.g., Updated description for HR team):" -Title "New Value"
}
if (-not $NewValue) {
    Write-Host "No new value provided. Exiting..."
    exit
}

# Modify the group attribute
Write-Host "Modifying group '$GroupName'..."
try {
    Set-ADGroup -Identity $GroupName -Replace @{$Attribute = $NewValue}
    Write-Host "Group '$GroupName' updated successfully. Attribute '$Attribute' set to '$NewValue'."
} catch {
    Write-Host "Failed to modify the group. Error: $_"
}