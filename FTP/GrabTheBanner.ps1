$tcp = New-Object System.Net.Sockets.TcpClient
$tcp.Connect("195.110.124.133", 21)
$stream = $tcp.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
Start-Sleep -Milliseconds 800
while ($stream.DataAvailable) { Write-Host $reader.ReadLine() }
$tcp.Close()