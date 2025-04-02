<#
.SYNOPSIS
Resets the password of the specified Active Directory user.

.DESCRIPTION
This script resets the password of a specified Active Directory user. The new password
is securely set and requires the user to change it at the next login.

.PARAMETER AccountName
The account name (SamAccountName) of the user whose password will be reset.

.EXAMPLE
ResetUserPassword.ps1 -AccountName "john.doe"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$AccountName
)

# Define the new password securely
$NewPassword = ConvertTo-SecureString "N3wP@ssw0rd!" -AsPlainText -Force # Replace with a secure password

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
    Write-Error "Failed to reset password for user: $AccountName. Error: $_"
}