$allEnums = Get-SCSMEnumeration | where {$_.DisplayName -ne $null}
foreach($thisEnum in $allEnums) {
    Write-host ($thisEnum.DisplayName + "`t" + $thisEnum.Name + "`t" + $thisEnum.Id)
}