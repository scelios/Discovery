& "..\Group Script\CreateGroup.ps1" -NoPopup:$true -GroupName "IncorrectGroupScope" -GroupScope "doesnotexist" -OrganizationalUnit "Groups" -Description "test"
& "..\Group Script\CreateGroup.ps1" -NoPopup:$true -GroupName "IncorrectGroupOU" -GroupScope "Global" -OrganizationalUnit "doesnotexist" -Description "test"

