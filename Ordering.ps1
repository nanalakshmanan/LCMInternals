configuration Ordering
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    File One
    {
        Contents        = 'One'
        DestinationPath = 'C:\Destination\One.txt'        
        #DependsOn       = "[File]Three"
    }

    File Two
    {
        Contents        = 'Two'
        DestinationPath = 'C:\Destination\Two.txt'
    }

    File Three
    {
        Contents        = 'Three'
        DestinationPath = 'C:\Destination\Three.txt'
    }
}