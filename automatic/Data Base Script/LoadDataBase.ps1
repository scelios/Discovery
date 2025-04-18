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

param (
    [bool]$NoPopup = $false,
    [string]$Delimiter = ","
)

Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Function to display a Save File dialog and get the file path
function Get-OpenFilePath {
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = (Get-Location).Path
    $OpenFileDialog.Filter = "CSV files (*.csv)|*.csv"
    $OpenFileDialog.Title = "Select the CSV file to load"
    $OpenFileDialog.FileName = ""

    if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Write-Host "Selected file path: $($OpenFileDialog.FileName)"
        return $OpenFileDialog.FileName
    } else {
        Write-Host "No file selected. Exiting..."
        return $null
    }
}

# Prompt the user for the file path using the Save File dialog
$FilePath = Get-OpenFilePath
# $FilePath = "C:\Users\Administrator\Documents\Discovery\automatic\Data Base Script\ADData.csv"

if (-not $FilePath) {
    Write-Host "No file path provided. Exiting..."
    exit
}

if (-not (Get-Command Get-ADGroup -ErrorAction SilentlyContinue)) {
    Write-Host "The Active Directory module is not available. Please install it to run this script."
    exit
}

if (-not (Test-Path $FilePath)) {
    Write-Host "The file path '$FilePath' is invalid or does not exist. Exiting..."
    exit
}

if (-not $FilePath.EndsWith(".csv")) {
    Write-Host "The selected file is not a CSV file. Please select a valid CSV file."
    exit
}

# Check if it is a file and not a directory
if ((Get-Item -Path $FilePath).PSIsContainer) {
    Write-Host "The path '$FilePath' is a directory, not a file. Please provide a valid file path."
    exit
}

# Check if the file is readable
if (-not (Get-Item -Path $FilePath).Attributes -match "ReadOnly") {
    Write-Host "The file at path '$FilePath' is not readable. Please check the file permissions."
    exit
}


# Prompt the user for the delimiter
if (!$NoPopup) {
    $Delimiter = Get-UserInput -Message "Enter the delimiter used in the CSV file (e.g., ',' for comma, ';' for semicolon):" -Title "CSV Delimiter"
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

# Load the CSV file
Write-Host "Loading the database from $FilePath with delimiter '$Delimiter' ..."
try {
    $Database = Import-Csv -Path $FilePath -Delimiter $Delimiter 
    # check if path is valid
    if (-not $Database) {
        Write-Host "Failed to load the database. Please check the file format and delimiter."
        exit
    }
    # Check if the CSV file has the required columns
    if (-not ($Database | Get-Member -Name "ObjectClass" -MemberType NoteProperty)) {
        Write-Host "The CSV file does not contain the required 'ObjectClass' column. Exiting..."
        exit
    }
    if (-not ($Database | Get-Member -Name "CN" -MemberType NoteProperty)) {
        Write-Host "The CSV file does not contain the required 'CN' column. Exiting..."
        exit
    }

    foreach ($Entry in $Database) {
        # Check if the entry is a user or group based on the 'ObjectClass' column
        if ($Entry.ObjectClass -eq "user") {
            if (-not $Entry.PSObject.Properties["CN"] -or -not $Entry.PSObject.Properties["Name"] -or -not $Entry.PSObject.Properties["Description"]  -or -not $($Entry.CN) -or -not $($Entry.Name)) {
                Write-Host "Skipping entry with missing or invalid parameter."
                continue
            }
            if (-not $Entry.CN) {
                Write-Host "Skipping entry with missing CN."
                continue
            }
            try {
                # Use a properly escaped filter
                $User = Get-ADUser -Filter "SamAccountName -eq '$($Entry.CN)'" -ErrorAction Stop
                if ($User) {
                    Write-Host "User $($Entry.CN) already exists. Skipping..."
                    continue
                }
            } catch {
                Write-Host "Error checking user $($Entry.CN): $_"
                continue
            }
            
            # Create a new user
            Write-Host "Creating user: $($Entry.CN)"
            New-ADUser `
                -Name $($Entry.CN) `
                -SamAccountName $($Entry.CN) `
                -Description $($Entry.Description) `
                -AccountPassword (ConvertTo-SecureString "DefaultP@ssw0rd" -AsPlainText -Force) `
                -ChangePasswordAtLogon $true `
                -Enabled $true

            # Add user to groups
            if ($Entry.MemberOf) {
                $Groups = $Entry.MemberOf -split ","
                foreach ($Group in $Groups) {
                    if (Get-ADGroup -Filter { Name -eq $Group }) {
                        Write-Host "Adding user $($Entry.Name) to group $Group"
                        Add-ADGroupMember -Identity $Group -Members $Entry.Name
                    } else {
                        Write-Host "Group $Group does not exist. Skipping..."
                    }
                }
            }
        } elseif ($Entry.ObjectClass -eq "group") {
            if (-not $Entry.PSObject.Properties["CN"] -or -not $Entry.PSObject.Properties["Description"] -or -not $($Entry.CN)) {
                Write-Host "Skipping entry with missing or invalid parameter."
                continue
            }
            if (-not $Entry.CN) {
                # Write-Host "Skipping entry with missing CN."
                continue
            }
            try {
                # Use a properly escaped filter
                $Group = Get-ADGroup -Filter "Name -eq '$($Entry.CN)'" -ErrorAction Stop
                if ($Group) {
                    # Write-Host "Group $($Entry.CN) already exists. Skipping..."
                    continue
                }
            } catch {
                Write-Host "Error checking group $($Entry.CN): $_"
                continue
            }
            # Create a new group
            Write-Host "Creating group: $($Entry.CN)"
            New-ADGroup `
                -Name $($Entry.CN) `
                -GroupScope Global `
                -GroupCategory Security `
                -Description $($Entry.Description)
        }
    }
} catch {
    Write-Host "Failed to load the database. Error: $_"
    return
}

