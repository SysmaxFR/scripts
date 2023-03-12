### PARAMETERS ###

$SoftwareDownload = "https://download.sysinternals.com/files/Sysmon.zip"
$ConfigDownload = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"

# LATEST VERSION ###
$SoftwareInfo = "https://raw.githubusercontent.com/MicrosoftDocs/sysinternals/main/sysinternals/downloads/sysmon.md"



### FUNCTIONS ###

function Start-SysmonSvcInstall()
{
    # Install Sysmon Service
    Write-host "--- Sysmon Software Install ---"
    if(Test-Path "$ENV:SystemRoot\sysmon64.exe"){ Remove-Item "$ENV:SystemRoot\sysmon64.exe" }
    if(Test-Path "$ENV:Temp\sysmon"){ Remove-Item "$ENV:Temp\sysmon" -Recurse }

    Invoke-WebRequest -Method "Get" -Uri $SoftwareDownload -Outfile "sysmon.zip"
    Expand-Archive "sysmon.zip" -Force
    Invoke-WebRequest -Method "Get" -Uri $ConfigDownload -OutFile "sysmon\sysmonconfig.xml" -UseBasicParsing
    Start-Process -FilePath "sysmon\Sysmon64.exe" -ArgumentList "-accepteula", "-i sysmon\sysmonconfig.xml" -Wait -NoNewWindow
}

function Start-SysmonSvcUpdate()
{
    # Update Sysmon Service
    $CurrentVersion = (Get-Item "C:\Windows\sysmon64.exe").VersionInfo.FileVersion
    $LatestVersion = (Invoke-WebRequest -Method "Get" -Uri $SoftwareInfo -UseBasicParsing).Content.Split([Environment]::NewLine) | Select-String -Pattern "# Sysmon v"
    $LatestVersion = $LatestVersion -Replace "# Sysmon v",""

    if($CurrentVersion -eq $LatestVersion)
    {
        Write-Host "--- Sysmon Software Up to Date ---"
    }
    else
    {
        Write-Host "--- Sysmon Software Update ---"
        Start-Process -FilePath "sysmon64.exe" -ArgumentList "-u" -Wait -NoNewWindow
        Start-SysmonsvcInstall
    }
}

function Start-SysmonConfUpdate()
{
    $CurrentConfigHash = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv\Parameters" -Name "ConfigHash"
    $CurrentConfigHash = $CurrentConfigHash -Replace "SHA256=",""
    Invoke-WebRequest -Method "Get" -Uri $ConfigDownload -OutFile "sysmonconfig.xml" -UseBasicParsing
    $LatestConfigHash = Get-FileHash -Path "sysmonconfig.xml" -Algorithm "SHA256"

    if($CurrentConfigHash -eq $LatestConfigHash.Hash)
    {
        write-host "--- Symon config Up to Date ---"
    }
    else
    {
        write-host "--- Symon Config Update ---"
        Start-Process -FilePath "sysmon64.exe" -ArgumentList "-c sysmonconfig.xml" -Wait -NoNewWindow
    }
}

function Start-SysmonUninstall()
{
    Start-Process -FilePath "sysmon64.exe" -ArgumentList "-u" -Wait -NoNewWindow
}


### MAIN ###

Set-Location $ENV:Temp
if((Get-Service -Name Sysmon*) -eq $null)
{
    # Install Sysmon Service
    Start-SysmonSvcInstall
}
else
{
    # Update Sysmon Service
    Start-SysmonSvcUpdate
       
    # Update config
    #Start-Process -FilePath "sysmon64.exe" -ArgumentList "-c" -Wait    # Current Config
    Start-SysmonConfUpdate
}
Remove-Item "sysmon*" -Recurse
