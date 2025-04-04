<#
.SYNOPSIS
Retrieves user information from the Active Directory server.

.DESCRIPTION
This script retrieves information about a specified Active Directory user. 
The user can specify the account name (SamAccountName) and optionally filter the attributes to retrieve.

.PARAMETER AccountName
The account name (SamAccountName) of the user whose information will be retrieved.

.PARAMETER Attributes
An optional list of attributes to retrieve. If not specified, all attributes will be retrieved.

.EXAMPLE
ReadUserInformation.ps1 -AccountName "john.doe" -Attributes "Title", "Department"
#>

function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the account name
$AccountName = Get-UserInput -Message "Enter the account name (SamAccountName) of the user whose information you want to retrieve (e.g., john.doe):" -Title "Account Name"

if (-not $AccountName) {
    Write-Host "No account name provided. Exiting..."
    exit
}

# Validate the account name format
if ($AccountName -match '[\\/:*?"<>|]') {
    Write-Error "AccountName contains invalid characters. Please use valid characters."
    exit
}

# Check if the account name exists in Active Directory
try {
    $User = Get-ADUser -Identity $AccountName -ErrorAction Stop
} catch {
    Write-Error "User with SamAccountName '$AccountName' does not exist in Active Directory."
    exit
}

# Prompt the user for the attributes to retrieve (optional)
$AttributesInput = Get-UserInput -Message "Enter the attribute to retrieve for the user (e.g., Title,Department), or leave blank to retrieve all properties:" -Title "Attributes"
if (-not $AttributesInput) {
    Write-Host "No attributes provided. Retrieving all properties..."
    $Attributes = "*"
} else {
    $Attributes = $AttributesInput -split ","
}
# Validate the attributes
foreach ($Attribute in $Attributes) {
    if ($Attribute -match '[\\/:?"<>|]') {
        Write-Error "Attribute '$Attribute' contains invalid characters. Please use valid characters."
        exit
    }
}

# Retrieve user information
Write-Host "Retrieving information for user: $AccountName..."
try {
    if ($Attributes -ne "*") {
        # Ensure no duplicate properties in the selection
        $UniqueAttributes = $Attributes | Where-Object { $_ -ne "SamAccountName" }
        $UserInfo = Get-ADUser -Identity $AccountName -Properties $Attributes
        Write-Host "Retrieved the following attributes for user $AccountName :"
        $UserInfo | Select-Object SamAccountName, $UniqueAttributes | Format-Table -AutoSize
    } else {
        # Retrieve all attributes
        $UserInfo = Get-ADUser -Identity $AccountName -Properties *
        Write-Host "Retrieved all attributes for user $AccountName :"
        $UserInfo | Format-List
    }
} catch {
    Write-Error "Failed to retrieve information for user: $AccountName. Error: $_"
}
