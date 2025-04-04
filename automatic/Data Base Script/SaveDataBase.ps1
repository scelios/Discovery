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
Import-Module ActiveDirectory

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Put the current path in the input box
$CurrentPath = Get-Location
$DefaultFilePath = Join-Path -Path $CurrentPath.Path -ChildPath "ADData.csv"

# Prompt the user for the file path with the current path as the default value
$FilePath = [Microsoft.VisualBasic.Interaction]::InputBox(
    "Enter the full path where the CSV file will be saved (e.g., C:\ADData.csv):",
    "CSV File Path",
    $DefaultFilePath
)

if (-not (Get-Command Get-ADGroup -ErrorAction SilentlyContinue)) {
    Write-Host "The Active Directory module is not available. Please install it to run this script."
    exit
}

if (-not $FilePath) {
    Write-Host "No file path provided. Exiting..."
    exit
}

# Check if the directory path is valid
$DirectoryPath = Split-Path -Path $FilePath -Parent
if (-not (Test-Path -Path $DirectoryPath)) {
    Write-Host "The specified directory does not exist. Please provide a valid path."
    exit
}
# Check if the file path is writable
if (-not (Test-Path -Path $DirectoryPath)) {
    Write-Host "The specified directory does not exist. Please provide a valid path."
    exit
}


# Prompt the user for the delimiter
$Delimiter = Get-UserInput -Message "Enter the delimiter to use in the CSV file (e.g., ',' for comma, ';' for semicolon):" -Title "CSV Delimiter"
if (-not $Delimiter) {
    Write-Host "No delimiter provided. Exiting..."
    exit
}

# Check user input
if ($Delimiter -notmatch "^[,;]$") {
    Write-Host "Invalid delimiter. Please use ',' for comma or ';' for semicolon."
    exit
}

# Check if the file already exists
if (Test-Path -Path $FilePath) {
    $Overwrite = Get-UserInput -Message "The file '$FilePath' already exists. Do you want to overwrite it? (yes/no):" -Title "File Exists"
    if ($Overwrite -ne "yes") {
        Write-Host "Exiting without overwriting the file."
        exit
    }
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

# Check if Properties are valid
foreach ($Property in $Properties) {
    if ($Property -notin $DefaultProperties) {
        Write-Host "Invalid property '$Property' specified. Please check the property names."
        exit
    }
}

# Combine default properties with user-specified properties
if ($Properties) {
    $AllProperties = $Properties
} else {
    $AllProperties = $DefaultProperties
}

try {
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
} catch {
    Write-Host "An error occurred while creating the database: $_"
    exit
}

Write-Host "Database successfully saved to $FilePath."