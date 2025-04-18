<#
.SYNOPSIS
Resets the password of the specified Active Directory user.
#>
param (
    [bool]$NoPopup = $false,
    [string]$AccountName
)

Add-Type -AssemblyName Microsoft.VisualBasic

# Function to display a pop-up and get user input
function Get-UserInput {
    param (
        [string]$Message,
        [string]$Title
    )
    [Microsoft.VisualBasic.Interaction]::InputBox($Message, $Title, "")
}

# Prompt the user for the account name
if (!$NoPopup) {
    $AccountName = Get-UserInput -Message "Enter the account name (SamAccountName) of the user whose password will be reset (e.g., john.doe):" -Title "Account Name"
}
if (-not $AccountName) {
    Write-Host "No account name provided. Exiting..."
    exit
}

# Define the new password securely
$NewPassword = ConvertTo-SecureString "newP@ssw0rd" -AsPlainText -Force # Replace with a secure password

# Reset the user's password
Write-Host "Resetting password for user: $AccountName..."
try {
    Set-ADAccountPassword -Identity $AccountName -NewPassword $NewPassword -Reset
    Write-Host "Password reset successfully for user: $AccountName."

    # Force the user to change the password at the next login
    Write-Host "Forcing user $AccountName to change password at next login..."
    Set-ADUser -Identity $AccountName -ChangePasswordAtLogon $true
    Write-Host "User $AccountName is now required to change password at next login."
} catch {
    Write-Host "Failed to reset password for user: $AccountName. Error: $_"
}