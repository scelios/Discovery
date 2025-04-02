<#
.SYNOPSIS
Creates a new Active Directory group.

.DESCRIPTION
This script creates a new Active Directory group with the specified name, organizational unit, group scope, and description.

.PARAMETER GroupName
The name of the group to create.

.PARAMETER OrganizationalUnit
The organizational unit where the group will be created.

.PARAMETER GroupScope
The scope of the group (e.g., Global, Universal, or DomainLocal).

.PARAMETER Description
The description of the group.

.EXAMPLE
CreateGroup.ps1 -GroupName "HR Team" -OrganizationalUnit "OU=Groups,DC=example,DC=com" -GroupScope "Global" -Description "Group for HR team members"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$OrganizationalUnit,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Global", "Universal", "DomainLocal")]
    [string]$GroupScope,

    [Parameter(Mandatory = $false)]
    [string]$Description
)

# Create the new group
Write-Host "Creating a new group: $GroupName..."
try {
    New-ADGroup -Name $GroupName -Path $OrganizationalUnit -GroupScope $GroupScope -Description $Description
    Write-Host "Group '$GroupName' created successfully."
} catch {
    Write-Error "Failed to create the group. Error: $_"
}