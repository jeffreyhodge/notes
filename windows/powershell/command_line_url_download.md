https://superuser.com/questions/25538/how-to-download-files-from-command-line-in-windows-like-wget-or-curl

```
$client = new-object System.Net.WebClient
$client.DownloadFile("http://www.xyz.net/file.txt","C:\tmp\file.txt")
```
