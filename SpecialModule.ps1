configuration SpecialModule
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.Where{$_.Role -eq 'DemoNode'}.NodeName
    {
        Script owner
        {
            GetScript = {@{}}
            SetScript = {Get-Process -id $pid}
            TestScript = {$false}
            PsDscRunAsCredential = (Get-Credential Administrator)
        }
    }
}