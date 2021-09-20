<#
.SYNOPSIS

A script to add Hyper-V antivirus exclusions.

.DESCRIPTION

A script to add Hyper-V antivirus exclusions. This script can be used for Windows Server 2016, 2019 and 2022

.NOTES

File Name:      Add-Hyper-V-Antivirus-exclusions-WS2016-WS2019-WS2022.ps1
Created:        22/09/2018
Last modified:  20/09/2021
Author:         Wim Matthyssen
PowerShell:     5.1 or above 
Requires:       -RunAsAdministrator
OS:             Windows Server 2016, Windows Server 2019 and Windows Server 2022
Version:        2.0
Action:         Change variables were needed to fit your needs
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

.\Add-Hyper-V-Antivirus-exclusions-WS2016-WS2019-WS2022.ps1

.LINK

https://tinyurl.com/y2cnhko3
#>

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$vmFolder = "E:\VMs"
$vsmpProcess = "Vmsp.exe"
$vmcomputeProcess = "Vmcompute.exe"

$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Add custom Hyper-V exclusions

Add-MpPreference -ExclusionPath $vmFolder
Add-MpPreference -ExclusionProcess $vsmpProcess
Add-MpPreference -ExclusionProcess $vmcomputeProcess

Write-Host ($writeEmptyLine + "# Custom Hyper-V exclusions added" + $$writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
