<#
.SYNOPSIS
Creates a new Active Directory group.

.DESCRIPTION
This script creates a new Active Directory group with the specified name, organizational unit, group scope, and description.

.EXAMPLE
CreateGroup.ps1
#>

Add-Type -AssemblyName Microsoft.VisualBasic

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the group name
$GroupName = Get-UserInput -Message "Enter the name of the group to create (e.g., HR Team):" -Title "Group Name"
if (-not $GroupName) {
    Write-Host "No group name provided. Exiting..."
    exit
}

# Prompt the user for the organizational unit
$OrganizationalUnit = Get-UserInput -Message "Enter the organizational unit (OU) where the group will be created (e.g., OU=Groups,DC=example,DC=com):" -Title "Organizational Unit"
if (-not $OrganizationalUnit) {
    Write-Host "No organizational unit provided. Exiting..."
    exit
}

# Prompt the user for the group scope
$GroupScope = Get-UserInput -Message "Enter the group scope (Global, Universal, or DomainLocal):" -Title "Group Scope"
if (-not $GroupScope -or ($GroupScope -notin @("Global", "Universal", "DomainLocal"))) {
    Write-Host "Invalid or no group scope provided. Exiting..."
    exit
}

# Prompt the user for the description (optional)
$Description = Get-UserInput -Message "Enter a description for the group (optional):" -Title "Group Description"

# Create the new group
Write-Host "Creating a new group: $GroupName..."
try {
    New-ADGroup -Name $GroupName -Path $OrganizationalUnit -GroupScope $GroupScope -Description $Description
    Write-Host "Group '$GroupName' created successfully."
} catch {
    Write-Error "Failed to create the group. Error: $_"
}