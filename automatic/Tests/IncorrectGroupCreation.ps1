$project_path = "C:\Users\Administrator\Documents\Discovery\automatic\Group Script"
& "$project_path\CreateGroup.ps1" -NoPopup:$true -GroupName "IncorrectGroupScope" -GroupScope "doesnotexist" -OrganizationalUnit "Groups" -Description "test"
& "$project_path\CreateGroup.ps1" -NoPopup:$true -GroupName "IncorrectGroupOU" -GroupScope "Global" -OrganizationalUnit "doesnotexist" -Description "test"

