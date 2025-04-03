<#
.SYNOPSIS
Creates a database (CSV file) to store every user and group from the Domain Controller.

.DESCRIPTION
This script retrieves all users and groups from the Active Directory Domain Controller
and saves the data into a CSV file. The user can specify the file path, delimiter, and
additional properties to include in the database.

.EXAMPLE
SaveDataBase.ps1
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

# Prompt the user for the file path
$FilePath = Get-UserInput -Message "Enter the full path where the CSV file will be saved (e.g., C:\ADData.csv):" -Title "CSV File Path"
if (-not $FilePath) {
    Write-Host "No file path provided. Exiting..."
    exit
}

# Prompt the user for the delimiter
$Delimiter = Get-UserInput -Message "Enter the delimiter to use in the CSV file (e.g., ',' for comma, ';' for semicolon):" -Title "CSV Delimiter"
if (-not $Delimiter) {
    Write-Host "No delimiter provided. Exiting..."
    exit
}

# Prompt the user for additional properties (optional)
$PropertiesInput = Get-UserInput -Message "Enter additional properties to include (comma-separated, e.g., Name,EmailAddress,MemberOf), or leave blank for defaults:" -Title "Additional Properties"
if ($PropertiesInput) {
    $Properties = $PropertiesInput -split ","
} else {
    $Properties = @()
}

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