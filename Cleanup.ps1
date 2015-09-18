Remove-Item -Recurse -Force C:\source
pushd C:\Windows\System32\Configuration
del *.mof
cd .\PartialConfigurations 
del *.mof
cd ..\ConfigurationStatus
del *.mof
popd
