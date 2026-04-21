$ftp = [System.Net.FtpWebRequest]::Create("ftp://195.110.124.133/")
$ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
$ftp.Credentials = New-Object System.Net.NetworkCredential("anonymous", "test@test.com")
try {
    $response = $ftp.GetResponse()
    Write-Host "ANONYMOUS LOGIN ALLOWED" -ForegroundColor Red
    $response.Close()
} catch {
    Write-Host "Anonymous login denied: $_" -ForegroundColor Green
}