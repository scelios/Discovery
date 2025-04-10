$pwd="C:\Users\Administrator\Documents\Discovery\automatic\User Script"
& "$pwd\UserCreation.ps1" -NoPopup:$true -AccountName "jannet.doe" -OUname "OU=Users" -DesiredGroup "doesntexist"
