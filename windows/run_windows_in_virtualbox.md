https://linuxize.com/post/how-to-install-virtualbox-on-centos-7/

make sure your kernel matches its kernel-devel
centos stream removes old kernel and kernel-devel quickly

```
yum install elfutils-devel

sudo wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d

sudo yum install VirtualBox-6.1

systemctl status vboxdrv

wget https://download.virtualbox.org/virtualbox/6.1.22/Oracle_VM_VirtualBox_Extension_Pack-6.1.22.vbox-extpack

VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.22.vbox-extpack

#maybe?
/sbin/vboxconfig

#if the extpack post script or vboxconfig bombs out check logs and install missing dependencies

cat /var/log/vbox-setup.log

yum install #whatever

/sbin/vboxconfig
```

virtualbox has an extension in the pack you downloaded that lets you rdp in and work on your vm
You need to open the port for that

```
#see your zone, probably public
firewall-cmd --get-zones
firewall-cmd --get-active-zones

#probably have to create the service for the port
#don't want to use 3389 if you ever want to run xrdp or other rdp server
firewall-cmd --permanent --new-service=vboxrdp
firewall-cmd --permanent --service=vboxrdp --add-protocol=tcp
firewall-cmd --permanent --service=vboxrdp --add-port=5587/tcp
firewall-cmd --permanent --zone=public --add-service=vboxrdp
firewall-cmd --reload
```

You can export and import vms from the cli
```
vboxmanage list vms
vboxmanage export win19 -o win19.ova
#on other box or wherever
vboxmanage import win19.ova
#you will get a new mac address by default, might be able to hard code, but that is dangerous
```

Great website on creating vms with cli:
https://www.cloudsavvyit.com/3118/how-to-create-virtualbox-vms-from-the-linux-terminal/

start your vm when the hypervisor/host boots (ok document):
https://docs.oracle.com/en/virtualization/virtualbox/6.0/admin/autostart.html

Use the config file from above and save it at /etc/vbox/autostart.conf

```
[jhodge@h2 ~]$ cat /etc/default/virtualbox
VBOXAUTOSTART_DB=/etc/vbox/autostartdb
VBOXAUTOSTART_CONFIG=/etc/vbox/autostart.conf
```

```
#vm should be powered off for some of these
mkdir /etc/vbox/autostartdb
chmod 1777 /etc/vbox/autostartdb
chgrp vboxusers /etc/vbox #this is probably uneccessary
usermod -aG vboxusers <yourusername>
VBoxManage setproperty autostartdbpath /etc/vbox/autostartdb/
vboxmanage modifyvm win19 --autostart-enabled on
vboxmanage modifyvm win19 --autostop-type savestate
systemctl enable vboxautostart-service
systemctl start vboxautostart-service
#this will probably fail due to selinux
#selinux is blocking su - <user> but vbox start up script routes
# stderr/stdout to /dev/null
#edit /usr/lib/virtualbox/vboxautostart-service.sh and change those
# nulls to a file somewhere like /tmp/whyvboxwhy
#then you'll need to use sealert -a /var/log/audit/audit.log to find
# what to do about the error
#in my case I had to do
ausearch -c 'vboxautostart-s' --raw | audit2allow -M my-vboxautostarts
semodule -X 300 -i my-vboxautostarts.pp
#but the fun didn't stop there
#The above commands will create a file called my-vboxautostarts.te before 
# the .pp file
#edit that file and add lines to allow root to su - without a password
[root@h2 ~]# cat my-vboxautostarts.te 

module my-vboxautostarts 1.0;

require {
	type user_home_t;
	type su_exec_t;
	type init_t;
	class file { create execute read };
        class passwd rootok;
}

#============= init_t ==============

#!!!! This avc is allowed in the current policy
allow init_t su_exec_t:file { execute read };

#!!!! This avc is allowed in the current policy
allow init_t user_home_t:file create;
allow init_t self:passwd rootok;
```

now apply that new selinux module or package or whatever it is
```
checkmodule -M -m -o my-vboxautostarts.mod my-vboxautostarts.te
semodule_package -o my-vboxautostarts.pp -m my-vboxautostarts.mod
semodule -X 300 -i my-vboxautostarts.pp
```

Maybe it will work now
```
systemctl restart vboxautostart-service
```
Good luck bro
