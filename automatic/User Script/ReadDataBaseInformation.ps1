<#
.SYNOPSIS
Retrieves information about all Active Directory users.

.DESCRIPTION
This script retrieves specific attributes of all Active Directory users based on the provided attribute filter.

.PARAMETER Attributes
The attributes to retrieve for all users.

.EXAMPLE
ReadDataBaseInformation.ps1 -Attributes "Title", "Department"
#>

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for AccountName
$AccountName = Get-UserInput -Message "Enter the account name (SamAccountName) of the user whose information you want to retrieve (e.g., john.doe):" -Title "Account Name"
if (-not $AccountName) {
    Write-Host "No account name provided. Retrieving information for all users..."
    $AccountName = "*"
}

# Validate the account name format
if ($AccountName -match '[\\/:?"<>|]') {
    Write-Host "AccountName contains invalid characters. Please use valid characters."
    exit
}


# Prompt the user for the attributes to retrieve
$AttributesInput = Get-UserInput -Message "Enter the attributes to retrieve for all users (comma-separated, e.g., Title,Department), or leave blank to retrieve all properties:" -Title "Attributes"
if (-not $AttributesInput) {
    Write-Host "No attributes provided. Retrieving all properties..."
    $Attributes = "*"
} else {
        if (-not $Attributes -contains "Name") {
        $AttributesInput = "Name," + $AttributesInput
    }
    $Attributes = $AttributesInput -split ","
}

# Retrieve all users' information
Write-Host "Retrieving information for all users..."
try {
    if ($Attributes -eq "*" -and $AccountName -eq "*") {
        # Retrieve all properties
        $Users = Get-ADUser -Filter * -Properties * -ErrorAction Stop
        $Users | Format-Table -AutoSize
    } else {
        # Ensure $Attributes is an array
        $AttributesArray = $Attributes
        if ($AccountName -ne "*") {
            $Users = Get-ADUser -Identity $AccountName -Properties $AttributesArray -ErrorAction Stop
        } else {
            $Users = Get-ADUser -Filter * -Properties $AttributesArray -ErrorAction Stop
        }
        $Users | Select-Object -Property $AttributesArray | Format-Table -AutoSize
    }
} catch {
    Write-Host "Failed to retrieve information for all users. Error: $_"
}