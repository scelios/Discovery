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
param(
    [bool]$NoPopup = $false,
    [string]$Delimiter,
    [string]$PropertiesInput

)

Add-Type -AssemblyName Microsoft.VisualBasic
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms


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
function Get-SaveFilePath {
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.InitialDirectory = Get-Location
    $SaveFileDialog.Filter = "CSV files (*.csv)|*.csv"
    $SaveFileDialog.Title = "Select the location of your CSV file"
    $SaveFileDialog.FileName = "ADData.csv"

    if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Write-Host "Selected file path: $($SaveFileDialog.FileName)"
        return $SaveFileDialog.FileName
    } else {
        return $null
    }
}
$FilePath = Get-SaveFilePath


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
if (!$NoPopup) {
    $Delimiter = Get-UserInput -Message "Enter the delimiter to use in the CSV file (e.g., ',' for comma, ';' for semicolon):" -Title "CSV Delimiter"
}
if (-not $Delimiter) {
    Write-Host "No delimiter provided. Exiting..."
    exit
}


# Check user input
if ($Delimiter -notmatch "^[,;]$") {
    Write-Host "Invalid delimiter. Please use ',' for comma or ';' for semicolon."
    exit
}

# Prompt the user for additional properties (optional)
if (!$NoPopup) {
    $PropertiesInput = Get-UserInput -Message "Enter additional properties to include (comma-separated, e.g., Name,EmailAddress,MemberOf), or * all of them:" -Title "Additional Properties"
}
if ($PropertiesInput) {
    $Properties = $PropertiesInput -split ","
} else {
    $Properties = @()
}



# Define valid properties for users and groups
$ValidUserProperties = @("SamAccountName", "Name", "DistinguishedName", "ObjectClass", "UserPrincipalName", "EmailAddress", "MemberOf", "LastLogonDate", "Enabled", "Description", "GivenName", "Surname", "Title", "Department", "Company", "StreetAddress", "City", "State", "PostalCode", "Country", "TelephoneNumber", "MobilePhone", "Fax", "HomePhone", "Manager")
$ValidGroupProperties = @("SamAccountName", "Name", "DistinguishedName", "ObjectClass", "Description", "GroupCategory", "GroupScope", "ManagedBy", "Members")

# Filter properties to only include valid ones
if ($Properties -eq $null -or $Properties -eq "*") {
    $all = $true
}
else{
    $all = $false
    $Properties = $Properties | Where-Object { $_ -in $ValidUserProperties -and $_ -in $ValidGroupProperties }
}



try {
    # Retrieve all users from Active Directory
    Write-Host "Retrieving all users from Active Directory..."
    if ($all) {
        $Users = Get-ADUser -Filter * -Property * -ErrorAction Stop
        $Groups = Get-ADGroup -Filter * -Property * -ErrorAction Stop
    }
    else {
        $Users = Get-ADUser -Filter * -Property $Properties -ErrorAction Stop
        $Groups = Get-ADGroup -Filter * -Property $Properties -ErrorAction Stop
    }
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