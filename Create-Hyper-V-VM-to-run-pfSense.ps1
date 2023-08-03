<#
.SYNOPSIS

A script used to create a Hyper-V VM for running pfSense.

.DESCRIPTION

A script used to create a Hyper-V VM for running pfSense.
This script will do all of the following:

Create the VM (generation 2, static memory) if it does not already exist.
Configure the VM (with 1 vCPU, checkpoints disabled (because for me it runs in my POC Demo environment), and VM notes configured).
Add a second Network adapter.
Create the Virtual Hard Disk folder.
Create a virtual disk (.vhdx) and attach it to the VM.
Disable VM Checkpoints for the Hyper-V virtual machine.
Add information to the VM Notes field.

.NOTES

Filename:       Create-Hyper-V-VM-to-run-pfSense.ps1
Created:        02/08/2023
Last modified:  02/08/2023
Author:         Wim Matthyssen
Version:        1.0
PowerShell:     Windows PowerShell
Requires:       PowerShell (v5.1)
Action:         Change variables were needed to fit your needs. 
Disclaimer:     This script is provided "as is" with no warranties.

.EXAMPLE

Run on Hyper-V host
.\Create-Hyper-V-VM-to-run-pfSense.ps1 -VMName <"your VMName name here"> 

-> .\Create-Hyper-V-VM-to-run-pfSense.ps1 -VMName slpfw001

.LINK

https://wmatthyssen.com/2023/08/03/create-a-hyper-v-vm-to-run-pfsense-with-a-powershell-script/
#>

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Parameters

param(
    # $vmName -> Name of Hyper-V VM
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] [string] $vmName
    )

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$vmLoc = #<your VM files location here> Location where the VM files will be stored. Example: "F:\VMs\" 
$networkSwitch1 = #<your LAN Network Switch name here> Name of the Network Switch (LAN). Example: "vSwitch-Private" 
$networkSwitch2 = #<your WAN Network Switch name here> Name of the Network Switch (WAN). Example: "vSwitch-External"
$vhdxFolder = #<your virtual hard disks folder name here> The name of the virtual hard disks folder. Example: "Virtual Hard Disks"
$vmNotes = #<your VM notes here> The VM notes here. Example: "Role: pfSense Firewall"+"`r`n"+"VM Generation: $vmGen"

$vmGen = "2" # VM Generation
$vmRamStatic = 1GB # Static memory assigned to the VM
$vCPU = 1 # Number of virtual CPUs
$automaticStartAction = "StartIfRunning" # Action that is run when the Hyper-V service is starting (Nothing, Start, StartIfRunning)
$automaticStartDelay = 60 # Number of seconds to wait before the automatic start action is run
$automaticStopAction = "Save" # Action that is run when the Hyper-V service is stopping
$vmLocFull = $vmLoc + $vmName
$vhdxDrive = $vmName + "-1" + ".vhdx"
$vhdxLocation = $vmLoc + $vmName + "\" + $vhdxFolder + "\"  + $vhdxDrive
$diskSize = 2GB                           

Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime = Get-Date -Format "dddd MM/dd/yyyy HH:mm"} | Out-Null 
$foregroundColor1 = "Green"
$foregroundColor2 = "Yellow"
$foregroundColor3 = "Red"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write script started

Write-Host ($writeEmptyLine + "# Script started. Without errors, it can take up to 1 minute to complete" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create the VM (generation 2, static memory) if it does not already exist

try {
    Get-VM -Name $vmName -ErrorAction Stop
    Write-Host ($writeEmptyLine + "# VM $vmName already exists, please validate" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor3 $writeEmptyLine
    Start-Sleep -s 3
    Write-Host -NoNewLine ("# Press any key to exit the script ..." + $writeEmptyLine)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine;
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null;
    return 
} catch {
    New-VM -Name $vmName `
    -Path $vmLoc `
    -NoVHD `
    -Generation $vmGen `
    -MemoryStartupBytes $vmRamStatic `
    -SwitchName $networkSwitch1 | Out-Null 
}

Write-Host ($writeEmptyLine + "# VM $vmName is created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Configure the VM (with 1 vCPU, checkpoints disabled (because for me it runs in my POC Demo environment), and VM notes configured)

Set-VM -Name $vmName `
    -ProcessorCount $vCPU `
    -AutomaticStartAction $automaticStartAction `
    -AutomaticStartDelay $automaticStartDelay `
    -AutomaticStopAction $automaticStopAction `
    -AutomaticCheckpointsEnabled $false | Out-Null 

Write-Host ($writeEmptyLine + "# VM $vmName is created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable Secure Boot

Set-VMFirmware -VMName $vmName -EnableSecureBoot Off

Write-Host ($writeEmptyLine + "# Secure Boot disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Add a second Network Adapter

Add-VMNetworkAdapter -VMName $vmName -SwitchName $networkSwitch2 | Out-Null

Write-Host ($writeEmptyLine + "# Second Network Adaptor added and connected to virtual switch $networkSwitch2" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create Virtual Hard Disk folder

New-Item -Path $vmLocFull -Name $vhdxFolder -ItemType "directory" | Out-Null

Write-Host ($writeEmptyLine + "# Virtual Hard Disk folder created" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create a virtual disk (.vhdx) and attach it to the VM

# Create .vhdx
New-VHD -SizeBytes $diskSize -Path $vhdxLocation | Out-Null

# Attach .vhdx
Add-VMHardDiskDrive -VMName $vmName -Path $vhdxLocation -ControllerType SCSI -ControllerNumber 0 | Out-Null

Write-Host ($writeEmptyLine + "# New .vhdx created an attached to VM $vmName" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable VM Checkpoints for the Hyper-V virtual machine

Set-VM -Name $vmName -CheckpointType Disabled | Out-Null

Write-Host ($writeEmptyLine + "# Checkpoints disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Add information to the VM Notes field

Set-VM -Name $vmName -Notes "$($vm.Notes)$vmNotes" -Confirm:$false | Out-Null

Write-Host ($writeEmptyLine + "# Info added into the VM Notes" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write script completed

Write-Host ($writeEmptyLine + "# Script completed" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
