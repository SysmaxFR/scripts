Add-PSSnapin VeeamPSSnapin

Write-Host "Search in progress ..."
$BackupJob = Get-VBRJob | Where { ($_.JobType -eq "Backup") -and ($_.VssOptions.VssSnapshotOptions.enabled -eq $true) -and ($_.VssOptions.VssSnapshotOptions.ApplicationProcessingEnabled -eq $true) }
Write-Host "Search ok"

Foreach ($VM in $BackupJob)
{
    $VM | Select @{ N="VM Name"; E={$VM.GetObjectsInJob().Name} }, @{ N="Job Name"; E={$VM.GetJobDisplayName()} }
}

#
# Search in progress ...
# Search ok
#
# VM Name                        Job Name                          
# -------                        -------                              
# WIN-BCKP-01                    Backup Job 03 - WIN-BCKP-01      
# {WIN-RDGATEWAY-02, WIN-RDS-02} Backup Job 06 - RDS-00              
# WIN-AD-01                      Backup Job 13 - WIN-AD-01
#
