
Import-Module smlets
$strDirectory = "c:\ManagementPacks\Backup_" + (Get-Date).ToString("yyyy.MM.dd")
if ((Test-Path -Path $strDirectory) -eq $false) {
    md $strDirectory -Force
}

Get-SCSMManagementPack | where {$_.Sealed -eq $false} | Export-SCSMManagementPack -TargetDirectory $strDirectory