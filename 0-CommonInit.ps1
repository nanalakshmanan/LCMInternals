$MyPath = Split-Path $MyInvocation.MyCommand.Path
$DemoRoot    = 'D:\Nana\Test'
$OutputPath  = "$DemoRoot\CompiledConfigurations"
$TraceFolder = "$DemoRoot\Traces"

Import-Module -Force "$MyPath\HelperMethods.psm1"

$DomainController    = 'Nana-XM-DC' 
$DNSServer           = '92.168.1.100'
$TestNode            = 'Nana-XM-Node'
$V1Node              = 'Nana-V1-Node'

if ($null -eq $Credential)
{
  $Credential = Get-Credential administrator
}
