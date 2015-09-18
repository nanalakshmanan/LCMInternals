$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# invoke consistency check and observe behavior
Invoke-ConsistencyCheck

dir "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltInProvCache"
dir $env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltInProvCache\MSFT_FileDirectoryConfiguration | %{Get-Content $_.FullName -Encoding Unicode}
rd -Recurse -Force $env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltInProvCache\MSFT_FileDirectoryConfiguration

# Note on what the cache is and how to utilize it in building resources
Invoke-ConsistencyCheck
dir "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltInProvCache"

# before a new configuration is applied this cache is cleared
# use of cache ensures that Test can be efficient and consistency check is quick