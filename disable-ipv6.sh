# 禁止ipv6
echo
echo -e "$yellow禁止ipv6$none"
echo "----------------------------------------------------------------"
sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

echo "net.ipv6.conf.all.disable_ipv6=1" >>/etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >>/etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6=1" >>/etc/sysctl.conf

sysctl -p >/dev/null 2>&1

echo
