$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# Every configuration run - new configuration or a consistency check is 
# identified with a unique id (job id). This can be used to retrieve results
# later
Invoke-ConsistencyCheck

Get-WinEvent -Path "$TraceFolder\DscTrace.etl" -Oldest -MaxEvents 1 | Format-List Message

# Bookmark - there is a difference in the way this is treated in v1 vs v2
# In V2, the job ids can be obtained using Get-DscConfigurationStatus
Get-DscConfigurationStatus | Format-List *
