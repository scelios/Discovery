<#
.SYNOPSIS
Retrieves information about a specified Active Directory group.

.DESCRIPTION
This script retrieves information about a specified Active Directory group. If no property name is provided, it retrieves all properties of the group.

.PARAMETER GroupName
The name of the group whose information will be retrieved.

.PARAMETER PropertyName
(Optional) The specific property of the group to retrieve. If not provided, all properties will be retrieved.

.EXAMPLE
ReadGroupInformation.ps1 -GroupName "HR Team"

.EXAMPLE
ReadGroupInformation.ps1
#>


function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the group name
$GroupName = Get-UserInput -Message "Enter the name of the group whose information you want to retrieve (e.g., HR Team):" -Title "Group Name"
if (-not $GroupName) {
    Write-Host "No group name provided. Exiting..."
    exit
}

# Prompt the user for the property name (optional)
$PropertyName = Get-UserInput -Message "Enter the property name to retrieve for the group (e.g., Description), or leave blank to retrieve all properties:" -Title "Property Name"

# Retrieve group information
Write-Host "Retrieving information for group '$GroupName'..."
try {
    # Get the group object
    $Group = Get-ADGroup -Identity $GroupName -Properties * -ErrorAction Stop

    if ($null -eq $Group) {
        Write-Error "Group '$GroupName' does not exist. Operation aborted."
        return
    }

    # Retrieve specific property or all properties
    if ($PropertyName) {
        if ($Group.PSObject.Properties[$PropertyName]) {
            Write-Host "Property '$PropertyName' of group '$GroupName': $($Group.$PropertyName)"
        } else {
            Write-Error "Property '$PropertyName' does not exist for group '$GroupName'."
        }
    } else {
        Write-Host "All properties of group '$GroupName':"
        $Group | Format-List
    }
} catch {
    Write-Error "Failed to retrieve group information. Error: $_"
}