red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

error() {
    echo -e "\n$red 输入错误! $none\n"
}

pause() {
	read -rsp "$(echo -e "按 $green Enter 回车键 $none 继续....或按 $red Ctrl + C $none 取消.")" -d $'\n'
	echo
}

# 说明
echo
echo -e "$yellow此脚本仅兼容于Debian 10+系统. 如果你的系统不符合,请Ctrl+C退出脚本$none"
echo -e "可以去 ${cyan}https://github.com/crazypeace/V2ray_VLESS_WebSocket_TLS_CaddyV2${none} 查看脚本整体思路和关键命令, 以便针对你自己的系统做出调整."
echo -e "有问题加群 ${cyan}https://t.me/+D8aqonnCR3s1NTRl${none}"
echo "----------------------------------------------------------------"
pause

# 准备工作
apt update
apt install -y bash curl sudo jq

# 安装V2ray最新版本
echo
echo -e "$yellow安装V2ray最新版本$none"
echo "----------------------------------------------------------------"
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

# 安装Caddy V2.4.6
# 最新的 Caddy V2.5.0 在 reverse_proxy 里引入了一个 trusted_proxies 先用老版本顶一段时间
echo
echo -e "$yellow安装Caddy V2.4.6$none"
echo "----------------------------------------------------------------"
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy=2.4.6

# 打开BBR
echo
echo -e "$yellow打开BBR$none"
echo "----------------------------------------------------------------"
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
sysctl -p >/dev/null 2>&1
echo

# 配置 VLESS_WebSocket_TLS 模式, 需要:域名, 分流path, 反代网站, V2ray内部端口, UUID
echo
echo -e "$yellow配置 VLESS_WebSocket_TLS 模式$none"
echo "----------------------------------------------------------------"

# UUID
uuid=$(cat /proc/sys/kernel/random/uuid)
while :; do
    echo -e "请输入 "$yellow"V2RayID"$none" "
    read -p "$(echo -e "(默认ID: ${cyan}${uuid}$none):")" v2ray_id
    [ -z "$v2ray_id" ] && v2ray_id=$uuid
    case $(echo $v2ray_id | sed 's/[a-z0-9]\{8\}-[a-z0-9]\{4\}-[a-z0-9]\{4\}-[a-z0-9]\{4\}-[a-z0-9]\{12\}//g') in
    "")
        echo
        echo
        echo -e "$yellow V2RayID = $cyan$v2ray_id$none"
        echo "----------------------------------------------------------------"
        echo
        break
        ;;
    *)
        error
        ;;
    esac
done

# V2ray内部端口
random=$(shuf -i20001-65535 -n1)
while :; do
    echo -e "请输入 "$yellow"V2Ray"$none" 端口 ["$magenta"1-65535"$none"], 不能选择 "$magenta"80"$none" 或 "$magenta"443"$none" 端口"
    read -p "$(echo -e "(默认端口: ${cyan}${random}$none):")" v2ray_port
    [ -z "$v2ray_port" ] && v2ray_port=$random
    case $v2ray_port in
    80)
        echo
        echo " ...都说了不能选择 80 端口了咯....."
        error
        ;;
    443)
        echo
        echo " ..都说了不能选择 443 端口了咯....."
        error
        ;;
    [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
        echo
        echo
        echo -e "$yellow V2Ray 端口 = $cyan$v2ray_port$none"
        echo "----------------------------------------------------------------"
        echo
        break
        ;;
    *)
        error
        ;;
    esac
done

# 域名
while :; do
    echo
    echo -e "请输入一个 ${magenta}正确的域名${none} Input your domain"
    read -p "(例如: mydomain.com): " domain
    [ -z "$domain" ] && error && continue
    echo
    echo
    echo -e "$yellow 你的域名 = $cyan$domain$none"
    echo "----------------------------------------------------------------"
    break
done

echo -e "如果你的小鸡是${magenta}双栈(同时有IPv4和IPv6的IP)${none}，请选择你把v2ray搭在哪个'网口'上"
echo "如果你不懂这段话是什么意思, 请直接回车"
read -p "$(echo -e "Input ${cyan}4${none} for IPv4, ${cyan}6${none} for IPv6:") " netstack
if [[ $netstack = "4" ]]; then
    ip=$(curl -4 -s https://api.myip.la)
elif [[ $netstack = "6" ]]; then 
    ip=$(curl -6 -s https://api.myip.la)
else
    ip=$(curl -s https://api.myip.la)
fi                

echo
echo
echo -e "$yellow 请将 $magenta$domain$none $yellow 解析到: $cyan$ip$none"
echo
echo -e "$yellow Resolve $magenta$domain$none $yellow to: $cyan$ip$none"
echo
echo -e "$yellow 请将 $magenta$domain$none $yellow 解析到: $cyan$ip$none"
echo "----------------------------------------------------------------"
echo

while :; do
    read -p "$(echo -e "(是否已经正确解析: [${magenta}Y$none]):") Is resolution correct?" record
    if [[ -z "$record" ]]; then
        error
    else
        if [[ "$record" == [Yy] ]]; then
            test_domain=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$domain&type=A" | jq -r '.Answer[0].data')
            if [[ "$test_domain" == "null" ]]; then
                network_stack="ipv6"
                test_domain=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$domain&type=AAAA" | jq -r '.Answer[0].data')
            fi

            if [[ $test_domain != $ip ]]; then
                echo
                echo -e "$red 检测域名解析错误....$none"
                echo
                echo -e " 你的域名: $yellow$domain$none 未解析到: $cyan$ip$none"
                echo
                echo -e " 你的域名当前解析到: $cyan$test_domain$none"
                echo
                echo "备注...如果你的域名是使用 Cloudflare 解析的话..在 Status 那里点一下那图标..让它变灰"
                echo
                exit 1
            fi

            echo
            echo
            echo -e "$yellow 域名解析 = ${cyan}我确定已经有解析了$none"
            echo "----------------------------------------------------------------"
            echo
            break
        else
            error
        fi
    fi
done

# 分流path
default_path=$(echo $uuid | sed 's/.*\([a-z0-9]\{12\}\)$/\1/g')
while :; do
    echo -e "请输入想要 ${magenta} 用来分流的路径 $none , 例如 /v2raypath , 那么只需要输入 v2raypath 即可"
    echo "Input the WebSocket path for V2ray"
    read -p "$(echo -e "(默认: [${cyan}${default_path}$none]):")" path
    [[ -z $path ]] && path=$default_path

    case $path in
    *[/$]*)
        echo
        echo -e " 由于这个脚本太辣鸡了..所以分流的路径不能包含$red / $none或$red $ $none这两个符号.... "
        echo
        error
        ;;
    *)
        echo
        echo
        echo -e "$yellow 分流的路径Path = ${cyan}/${path}$none"
        echo "----------------------------------------------------------------"
        echo
        break
        ;;
    esac
done

# 反代伪装网站
while :; do
    echo -e "请输入 ${magenta}一个正确的 $none ${cyan}网址$none 用来作为 ${cyan}网站的伪装$none , 例如 https://zelikk.blogspot.com"
    echo "Input a camouflage site. When GFW visit your domain, the camouflage site will display."
    read -p "$(echo -e "(默认: [${cyan}https://zelikk.blogspot.com$none]):")" proxy_site
    [[ -z $proxy_site ]] && proxy_site="https://zelikk.blogspot.com"

    case $proxy_site in
    *[#$]*)
        echo
        echo -e " 由于这个脚本太辣鸡了..所以伪装的网址不能包含$red # $none或$red $ $none这两个符号.... "
        echo
        error
        ;;
    *)
        echo
        echo
        echo -e "$yellow 伪装的网址camouflage site = ${cyan}${proxy_site}$none"
        echo "----------------------------------------------------------------"
        echo
        break
        ;;
    esac
done

# 配置 /usr/local/etc/v2ray/config.json
echo
echo -e "$yellow配置 /usr/local/etc/v2ray/config.json$none"
echo "----------------------------------------------------------------"
cat >/usr/local/etc/v2ray/config.json <<-EOF
{ // VLESS + WebSocket + TLS
    "log": {
        "access": "/var/log/v2ray/access.log",
        "error": "/var/log/v2ray/error.log",
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": $v2ray_port,             // ***
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$v2ray_id",             // ***
                        "level": 1,
                        "alterId": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws"
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIP"
            },
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
    "dns": {
        "servers": [
            "https+local://8.8.8.8/dns-query",
            "8.8.8.8",
            "1.1.1.1",
            "localhost"
        ]
    },
    "routing": {
        "domainStrategy": "IPOnDemand",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "0.0.0.0/8",
                    "10.0.0.0/8",
                    "100.64.0.0/10",
                    "127.0.0.0/8",
                    "169.254.0.0/16",
                    "172.16.0.0/12",
                    "192.0.0.0/24",
                    "192.0.2.0/24",
                    "192.168.0.0/16",
                    "198.18.0.0/15",
                    "198.51.100.0/24",
                    "203.0.113.0/24",
                    "::1/128",
                    "fc00::/7",
                    "fe80::/10"
                ],
                "outboundTag": "blocked"
            },
            {
                "type": "field",
                "protocol": [
                    "bittorrent"
                ],
                "outboundTag": "blocked"
            }
        ]
    }
}
EOF

# 配置 /etc/caddy/Caddyfile
echo
echo -e "$yellow配置 /etc/caddy/Caddyfile$none"
echo "----------------------------------------------------------------"
cat >/etc/caddy/Caddyfile <<-EOF
$domain
{
    tls Y3JhenlwZWFjZQ@gmail.com
    encode gzip

    handle_path /$path {
        reverse_proxy localhost:$v2ray_port
    }
    handle {
        reverse_proxy $proxy_site {
            header_up Host {upstream_hostport}
            header_up X-Forwarded-Host {host}
        }
    }
}
EOF

# 重启 V2Ray
echo
echo -e "$yellow重启 V2Ray$none"
echo "----------------------------------------------------------------"
service v2ray restart

# 重启 CaddyV2
echo
echo -e "$yellow重启 CaddyV2$none"
echo "----------------------------------------------------------------"
service caddy restart

echo
echo
echo "---------- V2Ray 配置信息 -------------"
echo
echo -e "$green ---提示..这是 VLESS 服务器配置--- $none"
echo
echo -e "$yellow 地址 (Address) = $cyan${domain}$none"
echo
echo -e "$yellow 端口 (Port) = ${cyan}443${none}"
echo
echo -e "$yellow 用户ID (User ID / UUID) = $cyan${v2ray_id}$none"
echo
echo -e "$yellow 流控 (Flow) = ${cyan}空${none}"
echo
echo -e "$yellow 加密 (Encryption) = ${cyan}none${none}"
echo
echo -e "$yellow 传输协议 (Network) = ${cyan}ws$none"
echo
echo -e "$yellow 伪装类型 (header type) = ${cyan}none$none"
echo
echo -e "$yellow 伪装域名 (host) = ${cyan}${domain}$none"
echo
echo -e "$yellow 路径 (path) = ${cyan}/${path}$none"
echo
echo -e "$yellow 底层传输安全 (TLS) = ${cyan}tls$none"
echo
echo "---------- V2Ray VLESS URL ----------"
echo -e "${cyan}vless://${v2ray_id}@${domain}:443?encryption=none&security=tls&type=ws&host=${domain}&path=${path}#VLESS_WSS_${domain}${none}"
echo "vless://${v2ray_id}@${domain}:443?encryption=none&security=tls&type=ws&host=${domain}&path=${path}#VLESS_WSS_${domain}" > _v2ray_vless_url_
echo
echo "---------- END -------------"
echo

# 如果是 IPv6 小鸡，用 WARP 创建 IPv4
if [[ "$network_stack" == "ipv6" ]]; then
    echo
    echo -e "$yellow这是一个 IPv6 小鸡，用 WARP 创建 IPv4$none"
    echo "----------------------------------------------------------------"
    pause

    # 安装 WARP IPv4
    bash <(curl -fsSL git.io/warp.sh) 4

    # 重启 V2Ray
    echo
    echo -e "$yellow重启 V2Ray$none"
    echo "----------------------------------------------------------------"
    service v2ray restart

    # 重启 CaddyV2
    echo
    echo -e "$yellow重启 CaddyV2$none"
    echo "----------------------------------------------------------------"
    service caddy restart
fi

