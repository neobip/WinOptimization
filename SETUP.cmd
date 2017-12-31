@echo off
title Windows 10 Setup Script -- by TJ

set installDir="%systemroot%\MaintDirectory"
set updateuser=MaintUser

echo This script should be run as administrator. 
echo For the following questions, only a capital "Y" will be accepted as "Yes."
PAUSE

set /p enableAdmin= Would you like to enable the default Windows Administrator Account? [Y/n]
echo %enableAdmin%

set /p disableLegacySearch= Would you like to disable legacy search indexing? [Y/n]
echo %disableLegacySearch%

set /p enableDiskCleanup= Would you like to disable legacy search indexing? [Y/n]
echo %enableDiskCleanup%

set /p enableRemoteSignedPS= Would you like to enable remote powershell code and install chocolatey repository? [Y/n]
echo %enableRemoteSignedPS%

if %enableAdmin%== Y (
    echo Enabling Windows Administrator
    net user administrator /active:yes
    net user administrator *
)

if %disableLegacySearch%== Y (
	echo Stopping Windows Legacy Search.
	net stop WSearch
)

if %enableDiskCleanup%== Y (
    echo Configuring Disk Cleanup. You will be asked about temporary files to remove from your system periodically.
	echo If you are in doubt, select everything except user files and thumbnails.
	PAUSE
	%systemroot%\SYSTEM32\cleanmgr.exe /Sageset:15
)

if %enableRemoteSignedPS%== Y (
	:: Enable Execution of Powershell Scripts - Generated registry values below.
	echo Installing registry keys required to run remote Powershell Scripts.
	REG add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d "RemoteSigned" /f
	REG add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d "RemoteSigned" /f
	
	echo Switching to Advanced Setup (Powershell.)
	echo Press Enter twice to confirm.

	powershell C:\MaintDirectory\Scripts\PowershellSetup.ps1

	::Evaluate This:
	::powershell C:\MaintDirectory\Scripts\Set-Privacy.ps1 -Strong -Admin

	:: This has to come after AdvancedSetup, or it will fail.
	:: Do not move
	echo Adding MaintUser to Admin Group.
	net localgroup administrators /add %updateuser%
)
