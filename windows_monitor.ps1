$Cpu = Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor
$pagespersec =  Get-WmiObject Win32_PerfFormattedData_PerfOS_Memory
$pageFiles =  Get-WmiObject Win32_PageFileUsage
$memory = Get-WmiObject Win32_OperatingSystem
$disk = Get-WmiObject Win32_PerfFormattedData_PerfDisk_LogicalDisk
$net = Get-WmiObject  Win32_PerfFormattedData_Tcpip_NetworkInterface
foreach ($object in $Cpu)
 {
    $name = $object.Name
	$usertime = $object.PercentUserTime
    $processorTime = $object.PercentProcessorTime
	$privilegedTime = $object.PercentPrivilegedTime
    $interruptTime = $object.PercentInterruptTime
	$idleTime = $object.PercentIdleTime
    "CPU,check=Cpu$name`_user,host=$env:COMPUTERNAME value=$usertime"
    "CPU,check=Cpu$name`_total,host=$env:COMPUTERNAME value=$processorTime"
    "CPU,check=Cpu$name`_privileged,host=$env:COMPUTERNAME value=$privilegedTime"
    "CPU,check=Cpu$name`_interrupt,host=$env:COMPUTERNAME value=$interruptTime"
    "CPU,check=Cpu$name`_idle,host=$env:COMPUTERNAME value=$idleTime"
    #$postParams1 = "CPU,check=Cpu$name`_total,host=$env:COMPUTERNAME value=$processorTime"
    #$postParams2 = "CPU,check=Cpu$name`_privileged,host=$env:COMPUTERNAME value=$privilegedTime"
    #$postParams3 = "CPU,check=Cpu$name`_interrupt,host=$env:COMPUTERNAME value=$interruptTime"
    #$postParams4 = "CPU,check=Cpu$name`_idle,host=$env:COMPUTERNAME value=$idleTime"
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams1
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams2
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams3
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams4
    }
foreach ($object in $pageFiles)
 {
    $name = $object.Name
    $name1 = $name.replace(":\" , "_")
    $name2 = $name1.replace("." , "_")
	$size = $object.AllocatedBaseSize
    $usage = $object.CurrentUsage*100/$size
    #write-host "$name2` - $size - $usage"
    "PageFiles,check=$name2`_usage,host=$env:COMPUTERNAME value=$usage"
    "PageFiles,check=$name2`_size,host=$env:COMPUTERNAME value=$size"
    #$postParams6 = "PageFiles,check=$name2`_size,host=$env:COMPUTERNAME value=$size"
    #invoke-RestMethod -Uri $uri -Method POST -Body $postParams5
    #invoke-RestMethod -Uri $uri -Method POST -Body $postParams6
}
foreach ($object in $memory)
 {
    $free = $object.FreePhysicalMemory/1024
    $free1 = [math]::Round($free)
    $size = $object.TotalVisibleMemorySize/1024
    $size1 = [math]::Round($size)
    $percentfree = $free*100/$size
    $percentfree1 = [math]::Round($percentfree) 
    $percentused = 100 -$percentfree1  
    #write-host "$percentfree1 - $percentused -$free1 -$size1"
    "Memory,check=total,host=$env:COMPUTERNAME value=$size1"
    "Memory,check=used,host=$env:COMPUTERNAME value=$percentused"
    #$postParams8 = "Memory,check=used,host=$env:COMPUTERNAME value=$percentused"
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams7
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams8
}
foreach ($object in $disk)
 {
    $name = $object.Name
    $name1 = $name.replace(":" , "_")
	$FreeMegabytes = $object.FreeMegabytes /1024
    $DiskReadBytesPersec = $object.DiskReadBytesPersec
	$DiskWriteBytesPersec = $object.DiskWriteBytesPersec
    $PercentFreeSpace = $object.PercentFreeSpace
	$PercentDiskReadTime = $object.PercentDiskReadTime
    $PercentDiskWriteTime =$object.PercentDiskWriteTime
    $PercentusedSpace = 100 - $PercentFreeSpace
    $logicsize = $FreeMegabytes * 100/$PercentFreeSpace
    $size = [math]::Round($logicsize)
    #write-host "$name`_ - $usertime - $processorTime - $privilegedTime - $interruptTime - $idleTime"
    "Partitions,check=$name1`_used,host=$env:COMPUTERNAME value=$PercentusedSpace"
    "Partitions,check=$name1`_size,host=$env:COMPUTERNAME value=$size"
    "Partitions,check=$name1`_free,host=$env:COMPUTERNAME value=$FreeMegabytes"
    "Partitions,check=$name1`_readBytes,host=$env:COMPUTERNAME value=$DiskReadBytesPersec"
    "Partitions,check=$name1`_writeBytes,host=$env:COMPUTERNAME value=$DiskWriteBytesPersec"
    "Partitions,check=$name1`_percentReadTime,host=$env:COMPUTERNAME value=$PercentDiskReadTime"
    "Partitions,check=$name1`_percentWriteTime,host=$env:COMPUTERNAME value=$PercentDiskWriteTime"
    #$postParams10 = "Partitions,check=$name1`_size,host=$env:COMPUTERNAME value=$size"
    #$postParams11 = "Partitions,check=$name1`_free,host=$env:COMPUTERNAME value=$FreeMegabytes"
    #$postParams12 = "Partitions,check=$name1`_readBytes,host=$env:COMPUTERNAME value=$DiskReadBytesPersec"
    #$postParams13 = "Partitions,check=$name1`_writeBytes,host=$env:COMPUTERNAME value=$DiskWriteBytesPersec"
    #$postParams14 = "Partitions,check=$name1`_percentReadTime,host=$env:COMPUTERNAME value=$PercentDiskReadTime"
    #$postParams15 = "Partitions,check=$name1`_percentWriteTime,host=$env:COMPUTERNAME value=$PercentDiskWriteTime"
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams9
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams10
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams11
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams12
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams13
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams14
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams15
    }
foreach ($object in $net)
 {
    $name = $object.Name
    $bitsReceivedPerSec = $object.BytesReceivedPerSec
    $bitsSentPerSec = $object.BytesSentPerSec
	
   # write-host "$name $bitsReceivedPerSec - $bitsSentPerSec"

    "Network,check=eth0-bitsReceived,host=$env:COMPUTERNAME value=$bitsReceivedPerSec"
    "Network,check=eth0-bitsSente,host=$env:COMPUTERNAME value=$bitsSentPerSec"
    #$postParams17 = "Network,check=eth0-bitsSente,host=$env:COMPUTERNAME value=$bitsSentPerSec"
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams16
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams17
}
foreach ($object in $pagespersec)
 {
    $pagespersec1 = $object.pagespersec
    "PageFiles,check=pagespersec,host=$env:COMPUTERNAME value=$pagespersec1" 
    #invoke-RestMethod -Uri $uri -Method POST -Body $postParams19
}

$time = (get-date) – (gcim Win32_OperatingSystem).LastBootUpTime | Select -ExpandProperty "TotalSeconds"
$uptime = [math]::Round($time)
    "Uptime,check=seconds,host=$env:COMPUTERNAME value=$uptime"
    #Invoke-RestMethod -Uri $uri -Method POST -Body $postParams18