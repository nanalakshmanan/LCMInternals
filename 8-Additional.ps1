$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# Additional pieces of information are written by the LCM
dir "$env:windir\system32\configuration\ConfigurationStatus"

# you can retrieve information using Get-DscConfigurationStatus
Get-DscConfigurationStatus -All  -OutVariable Status | Format-Table Status, StartDate, Type, Mode, RebootRequested, JobId -AutoSize

