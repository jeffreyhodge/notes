# Install windows and set up openssh server and remote desktop server

see this article for using a vm - https://github.com/jeffreyhodge/notes/blob/master/run_windows_in_virtualbox.md

get the evaluation copy:
https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019

install it in a vm or directly on a box

didn't figure out how to install over pxe, looks like a mess, have to use something called winp

You can install the windows subsystem linux but you will have to install a linux distro along with it, and you probably don't need it, but to enable it anyway:
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
see this for more info - https://docs.microsoft.com/en-us/windows/wsl/install-manual

You do want to get OpenSSH on the system because guis are the worst
```
#need to update windows first or your might run into an issue like I did
# where you can't install the server software
Install-Module PSWindowsUpdate
get-WindowsUpdate
Install-WindowsUpdate
```
Things got a little funky and I had to reboot of course, but after that I was able to get the ssh stuff installed
```
GetWindowsCapability -Online | ? Name -like 'OpenSSH*'
Add-WindowsCapability -Online -Name OpenSSH.Server ~~~~0.0.1.0
Set-Service -Name ssh-agent -StartupType 'Automatic'
Start-Service sshd
Get-NetFirewallRule -Name *ssh*
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```
You might have to restart to get this to take effect

How to enable remote desktop connections
```
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Termina
l Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```
