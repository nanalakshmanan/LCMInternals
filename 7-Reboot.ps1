$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# If a reboot is required, pending.mof remains so post reboot LCM 
# can process the same
psedit "$ScriptPath\RebootRequired.ps1"
. "$ScriptPath\RebootRequired.ps1"
RebootRequired -OutputPath "$OutputPath\RebootRequired"
Start-DscConfiguration -Path "$OutputPath\RebootRequired" -Force -ComputerName localhost -Wait -Verbose

Get-DscLocalConfigurationManager

# the state is persisted as well - configuration status and output as binary file
# stop process containing dsccore.dll
Get-Process wmiprvse | where modules -match  "dsccore.dll" | Stop-Process -Force

Get-DscLocalConfigurationManager

# Bookmark - certain operations behave differently based on 
# pending configuration 
Get-DscConfiguration

# reset the need for reboot
Start-DscConfiguration -Path "$OutputPath\HeloWorld" -Force -ComputerName localhost -Wait

