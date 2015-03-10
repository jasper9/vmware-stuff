$vc = Connect-VIServer vc.fqdn.com -User administrator@vsphere.local
#Define the VSANcluster where you would like the rules created
$Cluster = "VSAN Cluster"
$VSANAlerts = @{
"esx.audit.vsan.clustering.enabled" = "Virtual SAN clustering service had been enabled"
"esx.clear.vob.vsan.pdl.online" = "Virtual SAN device has come online."
"esx.clear.vsan.clustering.enabled" = "Virtual SAN clustering services have now been enabled."
"esx.clear.vsan.vsan.network.available" = "Virtual SAN now has at least one active network configuration."
"esx.clear.vsan.vsan.vmknic.ready" = "A previously reported vmknic now has a valid IP."
"esx.problem.vob.vsan.lsom.componentthreshold" = "Virtual SAN Node: Near node component count limit."
"esx.problem.vob.vsan.lsom.diskerror" = "Virtual SAN device is under permanent error."
"esx.problem.vob.vsan.lsom.diskgrouplimit" = "Failed to create a new disk group."
"esx.problem.vob.vsan.lsom.disklimit" = "Failed to add disk to disk group."
"esx.problem.vob.vsan.pdl.offline" = "Virtual SAN device has gone offline."
"esx.problem.vsan.clustering.disabled" = "Virtual SAN clustering services have been disabled."
"esx.problem.vsan.lsom.congestionthreshold" = "Virtual SAN device Memory/SSD congestion has changed."
"esx.problem.vsan.net.not.ready" = "A vmknic added to Virtual SAN network config doesn’t have valid IP."
"esx.problem.vsan.net.redundancy.lost" = "Virtual SAN doesn’t haven any redundancy in its network configuration."
"esx.problem.vsan.net.redundancy.reduced" = "Virtual SAN is operating on reduced network redundancy."
"esx.problem.vsan.no.network.connectivity" = "Virtual SAN doesn’t have any networking configuration for use."
"esx.audit.vsan.net.vnic.added" = "Virtual SAN NIC has been added."
"esx.audit.vsan.net.vnic.deleted" = "Virtual SAN NIC has been deleted."
"esx.problem.vob.vsan.dom.lsefixed" = "Virtual SAN detected and fixed a medium error on disk."
"esx.problem.vob.vsan.dom.nospaceduringresync" = "Resync encountered no space error."
"esx.problem.vsan.dom.init.failed.status" = "Virtual SAN Distributed Object Manager failed to initialize."
"esx.problem.vob.vsan.lsom.disklimit2" = "Failed to add disk to disk group in VSAN 6.0."
"vprob.vob.vsan.pdl.offline" = "Virtual SAN device has gone offline in VSAN 6.0."
}
$alarmMgr = Get-View AlarmManager
$entity = Get-Cluster $Cluster | Get-View
$VSANAlerts.Keys | Foreach {
                $Name = $VSANAlerts.Get_Item($_)
                $Value = $_
                # Create the Alarm Spec
                $alarm = New-Object VMware.Vim.AlarmSpec
                $alarm.Name = $Name
                $alarm.Description = $Name
                $alarm.Enabled = $TRUE
                $expression = New-Object VMware.Vim.EventAlarmExpression
                $expression.EventType = $null
                $expression.eventTypeId = $Value
                $expression.objectType = "HostSystem"
                $expression.status = "red"
                $alarm.expression = New-Object VMware.Vim.OrAlarmExpression
                $alarm.expression.expression += $expression
                $alarm.setting = New-Object VMware.Vim.AlarmSetting
                $alarm.setting.reportingFrequency = 0
                $alarm.setting.toleranceRange = 0
                # Create the Alarm
                Write-Host "Creating Alarm on $Cluster for $Name"
                $CreatedAlarm = $alarmMgr.CreateAlarm($entity.MoRef, $alarm)
}
Write-Host "All Alarms Added to $Cluster"
Disconnect-VIServer -Server $vc -Confirm:$false


