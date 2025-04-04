<#
.SYNOPSIS
Loads a database from a specified CSV file.

.DESCRIPTION
This script reads a CSV file containing user and group data from Active Directory
and loads it into memory for further processing or analysis. The user can specify
the file path and the delimiter used in the CSV file.

.EXAMPLE
LoadDataBase.ps1
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
# Check if the file exists
if (-not (Test-Path -Path $FilePath)) {
    Write-Host "The file at path '$FilePath' does not exist. Please provide a valid path."
    exit
}

# Check if the file is readable
if (-not (Get-Item -Path $FilePath).Attributes -match "ReadOnly") {
    Write-Host "The file at path '$FilePath' is not readable. Please check the file permissions."
    exit
}


# Prompt the user for the delimiter
$Delimiter = Get-UserInput -Message "Enter the delimiter used in the CSV file (e.g., ',' for comma, ';' for semicolon):" -Title "CSV Delimiter"
if (-not $Delimiter) {
    Write-Host "No delimiter provided. Exiting..."
    exit
}

# Load the CSV file
Write-Host "Loading the database from $FilePath with delimiter '$Delimiter'..."
try {
    $Database = Import-Csv -Path $FilePath -Delimiter $Delimiter
    Write-Host "Database successfully loaded."
    # Output the loaded data
    Write-Host "Displaying the first 10 entries in the database:"
    $Database | Select-Object -First 10 | Format-Table -AutoSize
} catch {
    Write-Error "Failed to load the database. Error: $_"
    return
}

