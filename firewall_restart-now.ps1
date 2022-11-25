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

# Fonctionne seulement avec powershell v7+.
if(!($PSVersionTable.PSVersion.Major -eq "7")){ Write-Host "Script use only PwSH v7"; Exit 1 }

$IP = 'X.X.X.X'
$Port = '0000'
$Username = 'admin'
$Password = 'monsupermdp'


$Uri = "https://"+$Ip+":"+$Port+"/api/sonicos"
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

# Ouverture de la session RestAPI, recuperation d'un cookie d'authentification.
$Session = Invoke-RestMethod -Uri "$Uri/auth" -Method POST -ContentType 'application/json' -SessionVariable 'Cookie' -SkipCertificateCheck -Authentication Basic -Credential $Credential
if ($Session.status.success -eq $false)
{
    Write-Host "Credentials error"
    Exit 1
}
Remove-Variable -Name Username, Password, Credential

$FirewallRestart = try { Invoke-RestMethod -Uri "$Uri/restart/now" -Method 'POST' -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck } catch { $_.ErrorDetails.Message | ConvertFrom-Json }
if ($FirewallRestart.status.success -eq $false)
{
    Write-Host $FirewallRestart.status.info
    Exit 1
}
else
{
    Write-Host "Reboot in few minutes"
    do {
        Write-Host "Waiting for restart"
        Start-Sleep -Seconds 1
    } while (Test-Connection $IP -count 1 -Quiet)
    Write-Host "Reboot -> Success"    
}

# Fermeture de la session RestAPI, suppression du cookie d'authentification.
$Session = Invoke-RestMethod -Uri "$Uri/auth" -Method DELETE -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck
