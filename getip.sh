get_ip() {

	ipv4=$(curl -4 -s ipv4.icanhazip.com)
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 https://api.ip.sb/ip)
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 https://api.ipify.org)
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 https://ip.seeip.org)
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 https://ifconfig.co/ip)
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 icanhazip.com)
	[[ -z $ipv4 ]] && ipv4=$(curl -s -4 myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ipv4 ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" 

    ipv6=$(curl -6 -s ipv6.icanhazip.com)
	[[ -z $ipv6 ]] && ipv6=$(curl -s -6 https://api.ip.sb/ip)
	[[ -z $ipv6 ]] && ipv6=$(curl -s -6 https://ip.seeip.org)
	[[ -z $ipv6 ]] && ipv6=$(curl -s -6 https://ifconfig.co/ip)	
	[[ -z $ipv6 ]] && ipv6=$(curl -s -6 icanhazip.com)
	[[ -z $ipv6 ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n"

	if [ $ipv6 ]; then
	ip=$ipv6 ##默认ipv6 edit by Scaleya
	else ip=$ipv4
	fi
}

# from https://github.com/wangxiaoke123/233v2ray
