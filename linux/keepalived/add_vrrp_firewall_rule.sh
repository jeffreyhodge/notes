# the source ip should be the real ip of the other system or sytems
firewall-cmd \
                  --add-rich-rule="rule family='ipv4' \
                                   source address='192.168.5.12' \
                                   protocol value='vrrp' accept" --permanent
