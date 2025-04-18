$Domain = (Get-ADDomain).DistinguishedName
$DomainDN = $Domain -replace '^.*?DC=', 'DC='
$OUnames = @("Administration", "Workspace")
$ComputerName = $env:COMPUTERNAME
$DomainName = $Domain -replace '^.*?DC=', 'DC='
$DomainName.toUpper()
if (1){
    Write-Host "Creating Organizational Units..."
    try {
        foreach ($OUname in $OUnames) {
            if (Get-ADOrganizationalUnit -Filter {Name -eq $OUname}) {
                Write-Host "Organizational Unit '$OUname' already exists. Skipping creation."
                continue
            }
            New-ADOrganizationalUnit -Name $OUname -Path $DomainDN
            Write-Host "Organizational Unit $OUname created successfully."
        }
    } catch {
        Write-Host "Error creating Organizational Units: $_"
    }
}
$GroupNames = @("Worker", "Direction", "Secretary", "CustomAdministrators")
$Description = @("Group for workers", "Group for direction", "Group for secretaries", "Group for administrators")

# Create Groups, folders and shares
if (1){
    Write-Host "Creating Groups..."
    try{
        foreach ($GroupName in $GroupNames) {
            if (Get-ADGroup -Filter {Name -eq $GroupName}) {
                Write-Host "Group '$GroupName' already exists. Skipping creation."
                continue
            }
            New-ADGroup -Name $GroupName -Path $DomainDN -GroupScope Global -Description $Description[$GroupNames.IndexOf($GroupName)]
            Write-Host "Group '$GroupName' created successfully."
        }

        # Write-Host "Creating folders..."
        $Folders = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
        foreach ($Folder in $Folders) {
            New-Item -Path $Folder -ItemType Directory -Force
            Write-Host "Folder '$Folder' created successfully."
        }
        # Share the folders
        foreach ($Folder in $Folders) {
            $ShareName = ($Folder -split ':[\\]')[1]
            Write-Host "Creating share for folder '$Folder' with name '$ShareName'..."
            if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
                Write-Host "Share '$ShareName' already exists. Skipping creation."
                continue
            }
            try {
                New-SmbShare -Name $ShareName -Path $Folder -ChangeAccess "Administrators" -Description "Shared folder for $ShareName"
                # New-SmbShare -Name $ShareName -Path $Folder -NoAccess "Everyone" -Description "Shared folder for $ShareName"
                Write-Host "Shared folder '$ShareName' created successfully."
            } catch {
                Write-Host "Error creating shared folder '$ShareName': $_"
            }
        }
    } catch {
        Write-Host "Error creating groups or folders: $_"
    }
}

# Create the users in the corresponding OUs
$Users = @(
    @{Name="Worker"; Surname="Smith"; OU="Administration"; Group="Worker"},
    @{Name="Direction"; Surname="Johnson"; OU="Workspace"; Group="Direction"},
    @{Name="Secretary"; Surname="Brown"; OU="Administration"; Group="Secretary"},
    @{Name="Admin"; Surname="Williams"; OU="Workspace"; Group="CustomAdministrators"}
)

if (1){
    foreach ($User in $Users) {
        $UserName = $User.Name
        $UserSurname = $User.Surname
        $OU = $User.OU
        $Group = $User.Group

        # Check if the user already exists
        if (Get-ADUser -Filter {Name -eq $UserName -and Surname -eq $UserSurname}) {
            Write-Host "User '$UserName $UserSurname' already exists. Skipping creation."
        }
        else {
            # Create the user in the specified OU
            New-ADUser -Name "$UserName $UserSurname" `
                -GivenName $UserName `
                -Surname $UserSurname `
                -SamAccountName "$UserName.$UserSurname" `
                -UserPrincipalName "$UserName.$UserSurname@$DomainDN" `
                -Path "OU=$OU,$DomainDN" `
                -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
                -Enabled $true
            Write-Host "User '$UserName $UserSurname' created successfully."
        }
        # Add the user to the corresponding group
        if (Get-ADGroupMember -Identity $Group -Recursive | Where-Object { $_.Name -eq "$UserName $UserSurname" }) {
            Write-Host "User '$UserName $UserSurname' is already a member of group '$Group'. Skipping addition."
            continue
        }
        Add-ADGroupMember -Identity $Group -Members "$UserName.$UserSurname"
        Write-Host "Added '$UserName $UserSurname' to group '$Group'."
    }
}

# $ReadPermissions = @{
#     "Worker" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources")
#     "Direction" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "Secretary" = @("\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "CustomAdministrators" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
# }
# $EditPermissions = @{
#     "Worker" = @("\\" + $ComputerName + "\WorkPlan")
#     "Direction" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "Secretary" = @("\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "CustomAdministrators" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
# }
# $CreatePermissions = @{
#     "Worker" = @("\\" + $ComputerName + "\WorkPlan")
#     "Direction" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "Secretary" = @("\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "CustomAdministrators" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
# }
# $DeletePermissions = @{
#     "Worker" = @()
#     "Direction" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "Secretary" = @("\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
#     "CustomAdministrators" = @("\\" + $ComputerName + "\WorkPlan", "\\" + $ComputerName + "\Management", "\\" + $ComputerName + "\HumanResources", "\\" + $ComputerName + "\Estimate", "\\" + $ComputerName + "\Client")
# }  

$ReadPermissions = @{
    "Worker" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources")
    "Direction" = @("C:\WorkPlan", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Secretary" = @("C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Administrator" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
}
$EditPermissions = @{
    "Worker" = @("C:\WorkPlan")
    "Direction" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Secretary" = @("C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Administrator" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
}
$CreatePermissions = @{
    "Worker" = @("C:\WorkPlan")
    "Direction" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Secretary" = @("C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Administrator" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
}
$DeletePermissions = @{
    "Worker" = @()
    "Direction" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Secretary" = @("C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
    "Administrator" = @("C:\WorkPlan", "C:\Management", "E:\HumanResources", "E:\Estimate", "E:\Client")
}

if (1){
    try {
        foreach ($GroupName in $GroupNames) {
            Write-Host "Setting permissions for group '$GroupName'..."
            if (-not (Get-ADGroup -Filter {Name -eq $GroupName})) {
                Write-Host "Group '$GroupName' does not exist. Skipping permission assignment."
                continue
            }
            $Group = Get-ADGroup -Identity $GroupName
            $ReadFolders = $ReadPermissions[$GroupName]
            $ReadFolders = $ReadFolders -split ' '
            $EditFolders = $EditPermissions[$GroupName]
            $EditFolders = $EditFolders -split ' '
            $CreateFolders = $CreatePermissions[$GroupName]
            $CreateFolders = $CreateFolders -split ' '
            $DeleteFolders = $DeletePermissions[$GroupName]
            $DeleteFolders = $DeleteFolders -split ' '
            # Write-Host "Setting permissions for group '$GroupName'..."
            foreach ($Folder in $ReadFolders) {
                if (-not (Test-Path $Folder)) {
                    Write-Host "Folder '$Folder' does not exist. Skipping permission assignment."
                    continue
                }
                if (-not (Get-ADGroup -Filter {Name -eq $GroupName})) {
                    Write-Host "Group '$GroupName' does not exist. Skipping permission assignment."
                    continue
                }
                try {
                    $acl = Get-Acl -Path $Folder
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("EXAMPLE\$GroupName", "Read", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Write-Host "Read permission granted to group '$GroupName' for folder '$Folder'."
                } catch {
                    Write-Host "Error setting permission for folder '$Folder': $_"
                }
            }
            
            foreach ($Folder in $EditFolders) {
                if (-not (Test-Path $Folder)) {
                    Write-Host "Folder '$Folder' does not exist. Skipping permission assignment."
                    continue
                }
                $acl = Get-Acl -Path $Folder
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("EXAMPLE\$GroupName", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Write-Host "Edit permission granted to group '$GroupName' for folder '$Folder'."
            }
            foreach ($Folder in $CreateFolders) {
                if (-not (Test-Path $Folder)) {
                    Write-Host "Folder '$Folder' does not exist. Skipping permission assignment."
                    continue
                }
                $acl = Get-Acl -Path $Folder
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("EXAMPLE\$GroupName", "CreateFiles", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Write-Host "Create permission granted to group '$GroupName' for folder '$Folder'."
            }

            foreach ($Folder in $DeleteFolders) {
                if (-not (Test-Path $Folder)) {
                    Write-Host "Folder '$Folder' does not exist. Skipping permission assignment."
                    continue
                }
                $acl = Get-Acl -Path $Folder
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("EXAMPLE\$GroupName", "Delete", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Write-Host "Delete permission granted to group '$GroupName' for folder '$Folder'."
            }
        }
        Write-Host "Permissions set successfully."
    } catch {
        Write-Host "Error setting permissions: $_"
    }
}

if (1){
    # Set the screen as the desktop background for all users
    try {
        $screen = "\\" + $ComputerName + "\Shared\Screen.png"
        if (Test-Path $screen) {
            Write-Host "Screen already exists. Skipping creation."
        } else {
            New-Item -Path $screen -ItemType File -Force
            Write-Host "Screen created successfully."
        }
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
        $regName = "Background"
        $regValue = 1
        Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
        Write-Host "Desktop background set successfully."
    }catch {
        Write-Host "Error setting desktop backgrounC: $_"
    }
}
# Define OpenOffice program deployement if required by each user
$OpenOfficePath = "\\" + $ComputerName + "\Shared\OpenOffice 4\program\soffice.exe"
$OpenOfficeShortcutPath = "\\" + $ComputerName + "\Shared\OpenOffice 4\OpenOffice 4.1.15.lnk"
if (1) {
    try {
        if (Test-Path $OpenOfficeShortcutPath) {
            Write-Host "OpenOffice shortcut already exists. Skipping creation."
        } else {
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($OpenOfficeShortcutPath)
            $Shortcut.TargetPath = $OpenOfficePath
            $Shortcut.Save()
            Write-Host "OpenOffice shortcut created successfully."
        }
    } catch {
        Write-Host "Error creating OpenOffice shortcut: $_"
    }
    # Define Slack non-optionnal installation for each new user
    $SlackPath = "\\" + $ComputerName + "\Shared\Slack\slack.exe"
    $SlackShortcutPath = "\\" + $ComputerName + "\Shared\slack\Slack.lnk"
    try {
        if (Test-Path $SlackShortcutPath) {
            Write-Host "Slack shortcut already exists. Skipping creation."
        } else {
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($SlackShortcutPath)
            $Shortcut.TargetPath = $SlackPath
            $Shortcut.Save()
            Write-Host "Slack shortcut created successfully."
        }
    } catch {
        Write-Host "Error creating Slack shortcut: $_"
    }
}


