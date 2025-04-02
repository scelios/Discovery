<#
.SYNOPSIS
Creates a database (CSV file) to store every user and group from the Domain Controller.

.DESCRIPTION
This script retrieves all users and groups from the Active Directory Domain Controller
and saves the data into a CSV file. The user can specify the file path, delimiter, and
additional properties to include in the database.

.PARAMETER FilePath
The path where the resulting .CSV file will be saved.

.PARAMETER Delimiter
The delimiter to use in the CSV file (e.g., ',' for comma, ';' for semicolon).

.PARAMETER Properties
An undefined number of additional properties to include in the database.

.EXAMPLE
SaveDataBase.ps1 -FilePath "C:\ADData.csv" -Delimiter ',' -Properties "Name", "EmailAddress", "MemberOf"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [string]$Delimiter,

    [Parameter(Mandatory = $false)]
    [string[]]$Properties
)

# Default properties to include in the database
$DefaultProperties = @("SamAccountName", "Name", "DistinguishedName", "ObjectClass")

# Combine default properties with user-specified properties
if ($Properties) {
    $AllProperties = $DefaultProperties + $Properties
} else {
    $AllProperties = $DefaultProperties
}

# Retrieve all users from Active Directory
Write-Host "Retrieving all users from Active Directory..."
$Users = Get-ADUser -Filter * -Property $AllProperties

# Retrieve all groups from Active Directory
Write-Host "Retrieving all groups from Active Directory..."
$Groups = Get-ADGroup -Filter * -Property $AllProperties

# Combine users and groups into a single collection
Write-Host "Combining users and groups into a single database..."
$Database = @()
$Database += $Users
$Database += $Groups

# Export the database to a CSV file
Write-Host "Exporting the database to $FilePath with delimiter '$Delimiter'..."
$Database | Select-Object $AllProperties | Export-Csv -Path $FilePath -Delimiter $Delimiter -NoTypeInformation

Write-Host "Database successfully saved to $FilePath."