<#
.SYNOPSIS
Loads a database from a specified CSV file.

.DESCRIPTION
This script reads a CSV file containing user and group data from Active Directory
and loads it into memory for further processing or analysis. The user can specify
the file path and the delimiter used in the CSV file.

.PARAMETER FilePath
The path to the .CSV file to load.

.PARAMETER Delimiter
The delimiter used in the CSV file (e.g., ',' for comma, ';' for semicolon).

.EXAMPLE
LoadDataBase.ps1 -FilePath "C:\ADData.csv" -Delimiter ','
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [string]$Delimiter
)

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