# 本脚本使用
InFaces=($(ls /sys/class/net/ | grep -E '^(eth|ens|eno|esp|enp|venet|vif)')) #找所有的网口

for i in "${InFaces[@]}"; do  # 从网口循环获取IP
    # 增加超时时间, 以免在某些网络环境下请求IPv6等待太久
    Public_IPv4=$(curl -4s --interface "$i" -m 2 https://www.cloudflare.com/cdn-cgi/trace | grep -oP "ip=\K.*$")
    Public_IPv6=$(curl -6s --interface "$i" -m 2 https://www.cloudflare.com/cdn-cgi/trace | grep -oP "ip=\K.*$")

    if [[ -n "$Public_IPv4" ]]; then  # 检查是否获取到IP地址
        IPv4="$Public_IPv4"
    fi
    if [[ -n "$Public_IPv6" ]]; then  # 检查是否获取到IP地址            
        IPv6="$Public_IPv6"
    fi
done
echo ${IPv4}
echo ${IPv6}

# 在很多VPS上执行无响应
ip=$(curl -s https://api.myip.la)

# from https://github.com/wangxiaoke123/233v2ray
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

# from https://owo.misaka.rest/xui-routing/
curl ipget.net

# from https://github.com/233boy/v2ray
curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -oP "ip=\K.*$"
# https://www.cloudflare.com/cdn-cgi/trace 返回的结果里面还有一个warp，可以用于判断是否通过warp访问的

# from TG "春风得意马蹄疾,一日看尽长安花" ID 1727149390
get_public_ip(){
    InFaces=($(ls /sys/class/net | grep -E '^(eth|ens|eno|esp|enp|venet|veth|vif)'))
    IP_API=(
        "api64.ipify.org"
        "ip.sb"
        "ifconfig.me"
        "icanhazip.com"
    )

    for iface in "${InFaces[@]}"; do
        for ip_api in "${IP_API[@]}"; do
            IPv4=$(curl -s4 --max-time 2 --interface "$iface" "$ip_api")
            IPv6=$(curl -s6 --max-time 2 --interface "$iface" "$ip_api")

            if [[ -n "$IPv4" || -n "$IPv6" ]]; then # 检查是否获取到IP地址
                break 2 # 获取到任一IP类型停止循环
            fi
        done
    done
}

#
curl -4L ifconfig.me
curl -6L ifconfig.me
