$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# The graph is evaluated and converted into an internal list
psedit "$ScriptPath\Ordering.ps1"
. "$ScriptPath\Ordering.ps1"
Ordering -OutputPath "$OutputPath\Ordering"

Trace-xDscConfiguration -Path "$OutputPath\Ordering" -Force -ComputerName localhost -Wait

$Events = Get-WinEvent -Path "$TraceFolder\DscTrace.etl" -Oldest
Get-Sequence $Events

# Introduce a depends on
psedit "$ScriptPath\Ordering.ps1"
. "$ScriptPath\Ordering.ps1"
Ordering -OutputPath "$OutputPath\Ordering"

Trace-xDscConfiguration -Path "$OutputPath\Ordering" -Force -ComputerName localhost -Wait

$Events = Get-WinEvent -Path "$TraceFolder\DscTrace.etl" -Oldest
Get-Sequence $Events

Start-DscConfiguration -Path "$OutputPath\Ordering" -Force -ComputerName localhost -Wait -Verbose

# if configuration is complete, then pending.mof is moved to current.mof
dir "$env:windir\system32\configuration"