$script:pssession = "DscTrace"
$script:Logman="$env:windir\system32\logman.exe"
$script:oplog = "/Operational"
$script:analyticlog="/Analytic"
$script:debuglog="/Debug"
$script:wevtutil="$env:windir\system32\wevtutil.exe"
$script:slparam = "sl"
$script:glparam = "gl"
$script:ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$Script:DemoRoot = 'D:\Nana\Test\'

function Get-Sequence
{
    param(

        [Parameter(Position=0)]
        [System.Array]
        $Events
    )

    $FilteredEvents = ($events | where id -eq 4332 )

    $SequenceArray = @()
    $string1 = 'Resource execution sequence :: '

    $FilteredEvents | % {


        $resource = $_.Message.SubString($_.Message.IndexOf($string1))
        $resource = $resource.Substring($string1.Length)        
        $SequenceArray += $resource.Split(',')
    }

    $SequenceArray

}

function Invoke-ConsistencyCheck
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $ComputerName='localhost',

        [Parameter(Position=1)]
        [PSCredential]
        $Credential
    )

    Write-Verbose "$script:ScriptPath"
    Enable-DscTrace
    $s = New-CimSession -ComputerName $ComputerName -Credential $Credential
    Invoke-CimMethod -Namespace root/microsoft/windows/desiredstateconfiguration -ClassName msft_dsclocalconfigurationmanager `
                        -MethodName performrequiredconfigurationchecks  -Arguments @{Flags=[uint32]1} -Verbose `
                            -CimSession $s 
    Disable-DscTrace
}


function Enable-DscTrace
{
	param (
        
        [string]
        $TraceFolder = "$($Script:DemoRoot)\Traces",

		[switch] $DoNotOverwriteExistingTrace
	)
	
    $provfile = [io.path]::GetTempFilename()
    
	$traceFileName = [string][Guid]::NewGuid()
	if ($DoNotOverwriteExistingTrace) {
		$fileName = [string][guid]::newguid()
		$logfile = "$TraceFolder\DscTrace_$fileName.etl" 
	} else {
		$logfile = "$TraceFolder\DscTrace.etl" 
	}
    
    "Microsoft-Windows-DSC 0 5" | out-file $provfile -encoding ascii
    
    
    if (!(Test-Path $TraceFolder))
    {
        mkdir -Force $TraceFolder | out-null
    }
    
    if (Test-Path $logfile)
    {
        Remove-Item -Force $logfile | out-null
    }
    
    Start-Trace -SessionName $script:pssession -OutputFilePath $logfile -ProviderFilePath $provfile -ets 
	
	remove-item $provfile -Force -ea 0
}

function Disable-DscTrace
{
    Stop-Trace -SessionName $script:pssession -ets
}

function Start-Trace
{
    Param(
    [Parameter(Mandatory=$true,
               Position=0)]               
    [string]
    $SessionName,    
    [Parameter(Position=1)]
    [string]
    $OutputFilePath,
    [Parameter(Position=2)]
    [string]
    $ProviderFilePath,
    [Parameter()]
    [Switch]
    $ETS,
    [Parameter()]
    [ValidateSet("bin", "bincirc", "csv", "tsv", "sql")]
    $Format,
    [Parameter()]
    [int]
    $MinBuffers=0,
    [Parameter()]
    [int]
    $MaxBuffers=256,
    [Parameter()]
    [int]
    $BufferSizeInKB = 0,    
    [Parameter()]
    [int]
    $MaxLogFileSizeInMB=0
    )
    
    Process
    {
        $executestring = " start $SessionName"
        
        if ($ETS)
        {
            $executestring += " -ets"
        }
        
        if ($OutputFilePath -ne $null)
        {
            $executestring += " -o $OutputFilePath"
        }
        
        if ($ProviderFilePath -ne $null)
        {
            $executestring += " -pf $ProviderFilePath"
        }
        
        if ($Format -ne $null)
        {
            $executestring += " -f $Format"
        }
        
        if ($MinBuffers -ne 0 -or $MaxBuffers -ne 256)
        {
            $executestring += " -nb $MinBuffers $MaxBuffers"
        }
        
        if ($BufferSizeInKB -ne 0)
        {
            $executestring += " -bs $BufferSizeInKB"
        }
        
        if ($MaxLogFileSizeInMB -ne 0)
        {
            $executestring += " -max $MaxLogFileSizeInMB"
        }
        
        & $script:Logman $executestring.Split(" ")

    }               
}

function Stop-Trace
{
    param(
    [Parameter(Mandatory=$true,               
               Position=0)]
    $SessionName,
    [Parameter()]
    [switch]
    $ETS
    )
    
    Process
    {
        if ($ETS)
        {
            & $script:Logman update $SessionName -ets
            & $script:Logman stop $SessionName -ets
        }
        else        
        {
            & $script:Logman update $SessionName
            & $script:Logman stop $SessionName 
        }
    }    
}

function Trace-xDscConfiguration
{
[CmdletBinding(DefaultParameterSetName='ComputerNameSet', SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
    [switch]
    ${Wait},

    [ValidateNotNullOrEmpty()]
    [switch]
    ${Force},

    [Parameter(ParameterSetName='CimSessionSet', Position=0)]
    [Parameter(ParameterSetName='ComputerNameSet', Position=0)]
    [string]
    ${Path},

    [string]
    ${JobName},

    [Parameter(ParameterSetName='ComputerNameSet', Position=1, ValueFromPipeline=$true)]
    [Alias('CN','ServerName')]
    [string[]]
    ${ComputerName},

    [Parameter(ParameterSetName='ComputerNameSet')]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    ${Credential},

    [Parameter(ParameterSetName='CimSessionSet')]
    [Parameter(ParameterSetName='ComputerNameSet')]
    [ValidateRange(0, 2147483647)]
    [int]
    ${ThrottleLimit},

    [Parameter(ParameterSetName='CimSessionSet', Mandatory=$true, ValueFromPipeline=$true)]
    [Microsoft.Management.Infrastructure.CimSession[]]
    ${CimSession})

    Enable-DscTrace
    Start-DscConfiguration @PSBoundParameters
    Disable-DscTrace
}

function LoadInstanceDoc()
{
    param
    (
        [String]$mofPath
    )
    
    # input data   
    [Byte[]] $configurationData = $null
    if ($mofPath)
    {
        $configurationData = [Byte[]][System.IO.File]::ReadAllBytes($mofPath) 
    }    
    
    return $configurationData
} 

function Start-xDscConfiguration
{
[CmdletBinding(DefaultParameterSetName='ComputerNameSet', SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
    [switch]
    ${Wait},

    [ValidateNotNullOrEmpty()]
    [switch]
    ${Force},

    [Parameter(ParameterSetName='CimSessionSet', Position=0)]
    [Parameter(ParameterSetName='ComputerNameSet', Position=0)]
    [string]
    ${Path},

    [string]
    ${JobName},
    [Switch]
    ${Disconnected},

    [Parameter(ParameterSetName='ComputerNameSet', Position=1, ValueFromPipeline=$true)]
    [Alias('CN','ServerName')]
    [string[]]
    ${ComputerName},

    [Parameter(ParameterSetName='ComputerNameSet')]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    ${Credential},

    [Parameter(ParameterSetName='CimSessionSet')]
    [Parameter(ParameterSetName='ComputerNameSet')]
    [ValidateRange(0, 2147483647)]
    [int]
    ${ThrottleLimit},

    [Parameter(ParameterSetName='CimSessionSet', Mandatory=$true, ValueFromPipeline=$true)]
    [Microsoft.Management.Infrastructure.CimSession[]]
    ${CimSession})

    if ($Disconnected)
    {
        dir $Path\*.mof | % {
            $Mof = $_.Name
            $FullName = $_.FullName

            foreach($c in $ComputerName)
            {
                if ($Mof -eq "$C.mof")
                {
                    $r = LoadInstanceDoc -mofPath $FullName
                    $jobid = [guid]::NewGuid()
                    $result = Invoke-CimMethod -Namespace root\microsoft/Windows/DesiredStateConfiguration -ClassName MSFT_DSCLocalConfigurationManager -MethodName SendConfigurationApplyAsync -Arguments @{configurationdata=[byte[]] $r;force=$true;jobid="{$($jobid.ToString())}"}
                    Write-Output $jobid
                }
            }
        }
    }
    else
    {
        throw "Not Supported, use -Disconnected"
    }
}


function Cleanup
{
    # clear all files in the configuration folder
    del "$env:windir\system32\configuration\*.mof"
    del "$env:windir\system32\configuration\joblogs\*.bmil" 2> $nulls
    del "$env:windir\system32\configuration\ConfigurationStatus\*.mof" 2> $nulls
    if (Test-Path C:\source)
    {
        ren c:\Source c:\temp2
    }

    if (Test-Path C:\Destination)
    {
        rd C:\Destination -Force -Recurse
    }

}

Export-ModuleMember Get-Sequence, Invoke-ConsistencyCheck, Enable-DscTrace, Disable-DscTrace, Trace-xDscConfiguration, Cleanup, Start-xDscConfiguration