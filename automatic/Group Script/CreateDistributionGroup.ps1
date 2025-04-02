<#
.SYNOPSIS
Creates a new distribution group for sending emails to multiple users at once.

.DESCRIPTION
This script creates a new distribution group in Active Directory with the specified name, organizational unit, group scope, and description.

.PARAMETER GroupName
The name of the distribution group to create.

.PARAMETER OrganizationalUnit
The organizational unit where the distribution group will be created.

.PARAMETER GroupScope
The scope of the distribution group (e.g., Global, Universal, or DomainLocal).

.PARAMETER Description
The description of the distribution group.

.EXAMPLE
CreateDistributionGroup.ps1 -GroupName "Marketing Team" -OrganizationalUnit "OU=Groups,DC=example,DC=com" -GroupScope "Universal" -Description "Distribution group for the marketing team"
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

# Create the new distribution group
Write-Host "Creating a new distribution group: $GroupName..."
try {
    New-ADGroup -Name $GroupName -Path $OrganizationalUnit -GroupScope $GroupScope -GroupCategory Distribution -Description $Description
    Write-Host "Distribution group '$GroupName' created successfully."
} catch {
    Write-Error "Failed to create the distribution group. Error: $_"
}