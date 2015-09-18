configuration RebootRequired
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Script reboot
    {
        GetScript = {@{}}
        SetScript = {$global:DSCMachineStatus = 1}
        TestScript = {$false}
    }
}