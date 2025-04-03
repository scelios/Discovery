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
$FilePath = Get-UserInput -Message "Enter the full path to the CSV file (e.g., C:\ADData.csv):" -Title "CSV File Path"
if (-not $FilePath) {
    Write-Host "No file path provided. Exiting..."
    exit
}

# Prompt the user for the delimiter
$Delimiter = Get-UserInput -Message "Enter the delimiter used in the CSV file (e.g., ',' for comma, ';' for semicolon):" -Title "CSV Delimiter"
if (-not $Delimiter) {
    Write-Host "No delimiter provided. Exiting..."
    exit
}

# Check if the file exists
if (-not (Test-Path -Path $FilePath)) {
    Write-Error "The file at path '$FilePath' does not exist."
    return
}

# Load the CSV file
Write-Host "Loading the database from $FilePath with delimiter '$Delimiter'..."
try {
    $Database = Import-Csv -Path $FilePath -Delimiter $Delimiter
    Write-Host "Database successfully loaded."
} catch {
    Write-Error "Failed to load the database. Error: $_"
    return
}

# Output the loaded data
Write-Host "Displaying the first 10 entries in the database:"
$Database | Select-Object -First 10 | Format-Table -AutoSize

# Return the database object for further use
return $Database