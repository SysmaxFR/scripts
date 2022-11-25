<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Sonicwall_Firewall-Restart
#>
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


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$GUI                             = New-Object system.Windows.Forms.Form
$GUI.ClientSize                  = New-Object System.Drawing.Point(267,236)
$GUI.text                        = "Firewall_Restart"
$GUI.TopMost                     = $false

$Send                            = New-Object system.Windows.Forms.Button
$Send.text                       = "Schedule"
$Send.width                      = 227
$Send.height                     = 30
$Send.location                   = New-Object System.Drawing.Point(22,185)
$Send.Font                       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$FirewallIP                      = New-Object system.Windows.Forms.TextBox
$FirewallIP.multiline            = $false
$FirewallIP.text                 = "192.168.0.254"
$FirewallIP.width                = 100
$FirewallIP.height               = 20
$FirewallIP.location             = New-Object System.Drawing.Point(22,25)
$FirewallIP.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$FirewallPort                    = New-Object system.Windows.Forms.TextBox
$FirewallPort.multiline          = $false
$FirewallPort.text               = "4443"
$FirewallPort.width              = 100
$FirewallPort.height             = 20
$FirewallPort.location           = New-Object System.Drawing.Point(22,55)
$FirewallPort.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$FirewallUsername                = New-Object system.Windows.Forms.TextBox
$FirewallUsername.multiline      = $false
$FirewallUsername.text           = "admin"
$FirewallUsername.width          = 100
$FirewallUsername.height         = 20
$FirewallUsername.location       = New-Object System.Drawing.Point(148,25)
$FirewallUsername.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$FireallPassword                 = New-Object system.Windows.Forms.TextBox
$FireallPassword.multiline       = $false
$FireallPassword.text            = "Password"
$FireallPassword.width           = 100
$FireallPassword.height          = 20
$FireallPassword.location        = New-Object System.Drawing.Point(148,55)
$FireallPassword.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RebootDate                      = New-Object system.Windows.Forms.TextBox
$RebootDate.multiline            = $false
$RebootDate.text                 = "03/01/2017"
$RebootDate.width                = 100
$RebootDate.height               = 20
$RebootDate.location             = New-Object System.Drawing.Point(22,98)
$RebootDate.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RebootTime                      = New-Object system.Windows.Forms.TextBox
$RebootTime.multiline            = $false
$RebootTime.text                 = "12:15"
$RebootTime.width                = 100
$RebootTime.height               = 20
$RebootTime.location             = New-Object System.Drawing.Point(148,98)
$RebootTime.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Progress                        = New-Object system.Windows.Forms.ProgressBar
$Progress.width                  = 168
$Progress.height                 = 20
$Progress.location               = New-Object System.Drawing.Point(22,153)

$Logs                            = New-Object system.Windows.Forms.Button
$Logs.text                       = "Logs"
$Logs.width                      = 45
$Logs.height                     = 20
$Logs.location                   = New-Object System.Drawing.Point(204,153)
$Logs.Font                       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$GUI.controls.AddRange(@($Send,$FirewallIP,$FirewallPort,$FirewallUsername,$FireallPassword,$RebootDate,$RebootTime,$Progress,$Logs))


#Write your logic code here

# Hide/View console Powershell
# Hide=0, ShowNormal = 1, ShowMinimized=2, ShowMaximized=3, Maximize=3, ShowNormalNoActivate=4, Show=5,
# Minimize=6, ShowMinNoActivate=7, ShowNoActivate=8, Restore=9, ShowDefault=10, ForceMinimized=11
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$ConsolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($ConsolePtr, 0)
$Logs.Add_Click(
{
    $ConsolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($ConsolePtr, 4)
})


# Send api requests
$Send.Add_Click(
{
    $Progress.Value = 10

    $IP = $FirewallIp.Text
    $Port = $FirewallPort.Text
    $Username = $FirewallUsername.Text
    $Password = $FireallPassword.Text

    $Uri = "https://"+$Ip+":"+$Port+"/api/sonicos"
    $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

    Write-Host $Credential.UserName
    Write-Host $Uri
    
    # Reformattage de la DataTime (concatenation et formatage API)
    $DateTime = [DateTime]::parseexact("$($RebootDate.Text) $($RebootTime.Text)", 'dd/MM/yyyy HH:mm', $null)
    $Schedule = ([DateTime]$DateTime).ToString('yyyyMMddHHmmss')

    Write-Host $DateTime

    # Ouverture de la session RestAPI, recuperation d'un cookie d'authentification.
    $Session = Invoke-RestMethod -Uri "$Uri/auth" -Method POST -ContentType 'application/json' -SessionVariable 'Cookie' -SkipCertificateCheck -Authentication Basic -Credential $Credential
    if( $Session.status.success -eq $false )
    {
        Write-Host "Credentials error"
    }
    Remove-Variable -Name Username, Password, Credential

    $FirewallRestart = try { Invoke-RestMethod -Uri "$Uri/restart/at/$Schedule" -Method 'POST' -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck } catch { $_.ErrorDetails.Message | ConvertFrom-Json }
    if( $FirewallRestart.status.success -eq $false )
    {
        Write-Host "Restart error : " $FirewallRestart.status.info
    }

    # Fermeture de la session RestAPI, suppression du cookie d'authentification.
    $Session = Invoke-RestMethod -Uri "$Uri/auth" -Method DELETE -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck

    $Progress.Value = 100
})

[void]$GUI.ShowDialog()


}
