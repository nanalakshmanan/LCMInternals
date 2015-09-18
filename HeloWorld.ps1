configuration HeloWorld
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    File f
    {
        Contents        = 'Helo World'
        DestinationPath = 'c:\temp\heloworld.txt'        
    }

    File x
    {
        SourcePath      = 'c:\Source'
        DestinationPath = 'c:\Destination'
        Recurse         = $true
    }

    foreach($Service in @('RemoteRegistry', 'TapiSrv'))
    {
        Service $Service
        {
            Name  = $Service
            State = 'Stopped'
        }
    }
} 