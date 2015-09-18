$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# meta configuration - new syntax
psedit "$ScriptPath\MetaConfiguration.ps1"
. "$ScriptPath\MetaConfiguration.ps1"
MetaConfig -OutputPath "$ScriptPath\CompiledConfigurations\MetaConfiguration"

# when no meta configuration is set, there is a default created
dir "$env:windir\system32\configuration"
del "$env:windir\system32\configuration\MetaConfig.mof"
Start-DscConfiguration -Path "$OutputPath\HeloWorld" -Force -ComputerName localhost -Wait -ver
dir "$env:windir\system32\configuration"
Get-Content -Encoding Unicode "$env:windir\system32\configuration\MetaConfig.mof" 

Set-DscLocalConfigurationManager -Path "$ScriptPath\CompiledConfigurations\MetaConfiguration" -ComputerName localhost -Verbose

Get-Content -Encoding Unicode "$env:windir\system32\configuration\MetaConfig.mof" 
