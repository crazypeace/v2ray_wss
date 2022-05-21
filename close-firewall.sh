
systemctl stop firewalld.service
systemctl disable firewalld.service
setenforce 0
ufw disable
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F 
iptables -F
iptables -X
netfilter-persistent save
