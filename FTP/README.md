# Use nmap for a full FTP audit (WSL or a Linux box)

```sh
nmap -sV -p 21 --script ftp-anon,ftp-bounce,ftp-syst,ftp-vuln-cve2010-4221 195.110.124.133
```