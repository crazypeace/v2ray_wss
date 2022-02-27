# V2ray_VLESS_WebSocket_TLS_CaddyV2
V2ray最新版本，VLESS_WebSocket_TLS模式，CaddyV2前置解除TLS和path

# 安装V2ray最新版本

bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

# 安装CaddyV2最新版本

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update

sudo apt install caddy

