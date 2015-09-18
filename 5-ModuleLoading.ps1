$ScriptPath  = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

# Ensures required modules are present, loads schema and validates the resource values
. "$ScriptPath\BadModuleVersion.ps1"
BadModuleVersion -OutputPath "$OutputPath\BadModuleVersion"
psedit "$OutputPath\BadModuleVersion\localhost.mof"

# modify module version
Start-DscConfiguration -Wait -Verbose -Force -Path "$OutputPath\BadModuleVersion" -ComputerName localhost 

# Bookmark - in V2, you can setup a repository so a module is downloaded even for Push

# PSDesiredStateConfiguration is treated specially, if the user
# does not explicitly specify a version
psedit "$ScriptPath\SpecialModule.ps1"
. "$ScriptPath\SpecialModule.ps1"

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            Role     = 'DemoNode'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

SpecialModule -OutputPath "$OutputPath\SpecialModule" -ConfigurationData $ConfigData
psedit "$OutputPath\SpecialModule\localhost.mof"

# once the module is loaded, the resource is loaded
# at this point, the resource schema is registered with WMI as well

# for class based resources the schema is generated
Import-Module $env:ProgramFiles\windowspowershell\modules\nContainer\nContainer.psm1

$type = (New-nContainer).GetType()

[Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::GenerateMofForType($type)
