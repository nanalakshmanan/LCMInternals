$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# Here is a sample configuration
psedit "$ScriptPath\HeloWorld.ps1"

# When this configuration is invoked it produces 
# a configuration document
. "$ScriptPath\HeloWorld.ps1"
HeloWorld -OutputPath "$OutputPath\HeloWorld"

# this document is a structured document
psedit "$OutputPath\HeloWorld\localhost.mof"

