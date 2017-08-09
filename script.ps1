$space = Get-WmiObject win32_volume
foreach ($object in $space) {
    $name = $object.DriveLetter
    if (-not $name) { $name = 0}
    $capacity = $object.capacity
    if (-not $capacity) { $capacity = 0}
    $free = $object.freeSpace
    if (-not $free) { $free = 0 }
    "salas,host=$env:COMPUTERNAME,volume=$name total=$capacity,libre=$free"
}
    