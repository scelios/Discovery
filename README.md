# Projet d'automatisation Windows Server

Ce projet a été réalisé dans le cadre d'un projet scolaire : objectif créer et automatiser le déploiement d'une infrastructure Windows Server (Active Directory, création d'OU, groupes, utilisateurs, partage de dossiers, etc.) et automatiser l'installation/configuration de logiciels et services.

Principales fonctionnalités
- Installation et promotion d'un contrôleur de domaine (création de forêt, jointure, installation AD DS) : [automatic/AD installation/CreateNewForestDomainController.ps1](automatic/AD%20installation/CreateNewForestDomainController.ps1), [automatic/AD installation/JoinExistingDomainController.ps1](automatic/AD%20installation/JoinExistingDomainController.ps1), [automatic/AD installation/ADPackageInstallor.ps1](automatic/AD%20installation/ADPackageInstallor.ps1)
- Gestion des utilisateurs (création, lecture, modification, réinitialisation de mot de passe) : [automatic/User Script/UserCreation.ps1](automatic/User%20Script/UserCreation.ps1), [automatic/User Script/ReadUserInformation.ps1](automatic/User%20Script/ReadUserInformation.ps1), [automatic/User Script/EditUserAttribute.ps1](automatic/User%20Script/EditUserAttribute.ps1), [automatic/User Script/ResetUserPassword.ps1](automatic/User%20Script/ResetUserPassword.ps1)
- Gestion des groupes (création, lecture, import, ajout/suppression de membres) : [automatic/Group Script/CreateGroup.ps1](automatic/Group%20Script/CreateGroup.ps1), [automatic/Group Script/AddUserToGroup.ps1](automatic/Group%20Script/AddUserToGroup.ps1), [automatic/Group Script/ImportGroup.ps1](automatic/Group%20Script/ImportGroup.ps1)
- Sauvegarde / chargement d'une "base de données" AD (CSV) : [automatic/Data Base Script/SaveDataBase.ps1](automatic/Data%20Base%20Script/SaveDataBase.ps1), [automatic/Data Base Script/LoadDataBase.ps1](automatic/Data%20Base%20Script/LoadDataBase.ps1)
- Scripts d'administration (création d'OU, groupes, partages, droits) : [automatic/Administrative.ps1](automatic/Administrative.ps1)
- Exemples et tests automatisés : [automatic/RunTests.ps1](automatic/RunTests.ps1) et scripts de tests dans [automatic/Tests/](automatic/Tests/) ou dans [Tests/](Tests/)

Comment l'utiliser
- Ouvrir PowerShell en tant qu'administrateur.
- Lancer un script avec les paramètres en ligne, par exemple :
  - Créer un utilisateur (mode non interactif) :
    powershell -File automatic/User\ Script/UserCreation.ps1 -NoPopup:$true -AccountName "john.doe" -OUname "Users" -DesiredGroup "IT"
  - Lancer tous les tests :
    powershell -File automatic/RunTests.ps1
- Les scripts acceptent le paramètre -NoPopup:$true pour exécuter sans interfaces graphiques.


Notes
- Les scripts utilisent le module ActiveDirectory ; exécuter sur un serveur ou poste avec les outils RSAT/AD disponibles.
- Beaucoup de scripts acceptent -NoPopup pour mode non interactif (utile pour tests automatisés).
- Adapter les mots de passe et adresses IP dans les scripts avant usage en production.

Licence / Crédits
Projet réalisé dans un cadre pédagogique. Scripts fournis à titre d'exemple et doivent être adaptés/validés avant utilisation en environnement réel.