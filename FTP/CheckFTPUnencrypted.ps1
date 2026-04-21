$tcp = New-Object System.Net.Sockets.TcpClient("195.110.124.133", 21)
$stream = $tcp.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)
Start-Sleep -Milliseconds 500
Write-Host $reader.ReadLine()  # banner

$writer.WriteLine("AUTH TLS")
$writer.Flush()
Start-Sleep -Milliseconds 300
Write-Host $reader.ReadLine()  # should say 234 if TLS supported
$tcp.Close()