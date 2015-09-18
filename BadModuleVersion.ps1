Configuration BadModuleVersion
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    xService service
    {
        Name  = 'RemoteRegistry'
        State = 'Stopped'
    }
}