Add-PSSnapin VeeamPSSnapin

$VirtualInfra = '172.18.201.3'
$ExcludeDirectoryInfra = "vcls", "vsan"
$ExcludeObjectInfra = "Folder", "Datacenter", "Vc"
$OnInfra = @()
$OnVeeam = @()


# Datacenver, Folder and VC are deleted because unnecessary in the return of veeam objects
$VMOnInfra = Find-VBRViEntity -VMsAndTemplates -Server (Get-VBRServer -Name $VirtualInfra) | Where { ($ExcludeObjectInfra -NotContains $_.Type) -and ($ExcludeDirectoryInfra -NotContains $_.VmFolderName) } 
Foreach ($VM in $VMOnInfra)
{
    $OnInfra += $VM.Name
}

$VMOnVeeam = Get-VBRJob | Where { ($_.JobType -eq "Backup") }
Foreach ($VM in $VMOnVeeam)
{
    $Onveeam += $VM.GetObjectsInJob().Name
}


$Diff = Compare-Object -ReferenceObject $OnInfra -DifferenceObject $OnVeeam
if($Diff -eq $null)
{
    Write-Host "No differences"
}
else
{
    Write-Host $Diff.InputObject "not saved"
}
