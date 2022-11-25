#
#   Manage > Appliance > Base Settings > SonicOS API
#   Enable SonicOS API
#       X Disable RFC-7616 HTTP Digest Access authentication
#       X Disable CHAP authentication
#       > Enable RFC-2617 HTTP Basic Access authentication
#       X Disable Public Key authentication
#       X Disable Two-Factor and Bearer Token Authentication
#       X Disable session security using RFC-7616 Digest authentication
#

if( !(Test-Path ".\PowerShell-7-win-x64") )
{
    Invoke-WebRequest https://github.com/PowerShell/PowerShell/releases/download/v7.1.1/PowerShell-7.1.1-win-x64.zip -OutFile PowerShell-7-win-x64.zip
    Expand-Archive ".\PowerShell-7-win-x64.zip"
    Remove-Item ".\PowerShell-7-win-x64.zip" -Force
}
.\PowerShell-7-win-x64\pwsh.exe -Command {


if(!($PSVersionTable.PSVersion.Major -eq "7")){ Write-Host "Script use only PwSH v7"; Exit 1 }

# Definition des variables.
$IP = "$env:FirewallIp"
$Port = "$env:FirewallPort"
$Username = "$env:FirewallUsername"
$Password = "$env:FirewallPassword"

$Uri = "https://"+$Ip+":"+$Port+"/api/sonicos"
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

# Ouverture de la session RestAPI, recuperation d'un cookie d'authentification.
$Session = Invoke-RestMethod -Uri "$Uri/auth" -Method POST -ContentType 'application/json' -SessionVariable 'Cookie' -SkipCertificateCheck -Authentication Basic -Credential $Credential
if ($Session.status.success -eq $false)
{
    # Retour en cas d erreur.
    write-host "<-Start Result->"
    write-host "Credentials error invalid"
    write-host "<-End Result->"
    Exit 1
}
Remove-Variable -Name Username, Password, Credential

# Lancement d'un redemarrage immediat.
$FirewallRestart = try { Invoke-RestMethod -Uri "$Uri/restart/now" -Method 'POST' -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck } catch { $_.ErrorDetails.Message | ConvertFrom-Json }
if ($FirewallRestart.status.success -eq $false)
{
    # Retour en cas d erreur.
    write-host "<-Start Result->"
    write-host "$FirewallRestart.status.info"
    write-host "<-End Result->"
    Exit 1
}
else
{
    # Retour de l attendre de redemarage
    write-host "<-Start Result->"
    Write-Host "Reboot in few minutes"
    do {
        Write-Host "Waiting for restart"
        Start-Sleep -Seconds 1
    } while (Test-Connection $IP -count 1 -Quiet)
    Write-Host "Reboot -> Success"
    write-host "<-End Result->"
}

# Fermeture de la session RestAPI, suppression du cookie d'authentification.
$Session = Invoke-RestMethod -Uri "$Uri/auth" -Method DELETE -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck


}
