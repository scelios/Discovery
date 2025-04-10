$project_path = "C:\Users\Administrator\Documents\Discovery\automatic"
& "$project_path\Group Script\CreateGroup.ps1" -NoPopup:$true -GroupName "IT" -GroupScope "DomainLocal" -OrganizationalUnit "Groups" -Description "test"
& "$project_path\User Script\UserCreation.ps1" -NoPopup:$true -AccountName "john.doe" -OUname "Users" -DesiredGroup "IT"