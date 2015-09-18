$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# run the document against a V4 (LTSB) node
copy "$OutputPath\HeloWorld\localhost.mof" "$OutputPath\HeloWorld\$V1Node.mof"

# run it against a V1 node
Start-DscConfiguration -Path "$OutputPath\Heloworld" -ComputerName $V1Node -Credential $Credential -Wait -Force -Verbose

# look at the mof file again
psedit "$OutputPath\HeloWorld\$V1Node.mof"