#!/bin/bash
set -e

echo "🚀 G2Ray-Light Ultra Lite Starting..."

# رفع apt و نصب پکیج‌ها
sudo rm -rf /var/lib/apt/lists/partial
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ca-certificates curl unzip uuid-runtime

# دانلود و نصب sing-box با sudo
echo "📥 Downloading sing-box..."
curl -L -o /tmp/sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v1.13.11/sing-box-1.13.11-linux-amd64.tar.gz"

sudo tar -xzf /tmp/sing-box.tar.gz -C /usr/local/bin/
sudo mv /usr/local/bin/sing-box-1.13.11-linux-amd64/sing-box /usr/local/bin/sing-box
sudo chmod +x /usr/local/bin/sing-box
sudo rm -rf /tmp/sing-box* /usr/local/bin/sing-box-1.13.11-linux-amd64

# متغیرها
UUID=$(uuidgen)
CODESPACE_NAME=${CODESPACE_NAME:-$(hostname)}
DOMAIN="${CODESPACE_NAME}.github.dev"

echo "🔑 UUID: ${UUID}"
echo "🌐 Domain: ${DOMAIN}"

# کانفیگ
sudo mkdir -p /etc/sing-box
cat > /tmp/config.json << EOF
{
  "log": { "level": "warn" },
  "inbounds": [{
    "type": "vless",
    "listen": "::",
    "listen_port": 443,
    "users": [{ "uuid": "${UUID}", "flow": "xtls-rprx-vision" }],
    "tls": {
      "enabled": true,
      "server_name": "${DOMAIN}",
      "alpn": ["h2", "http/1.1"]
    }
  }],
  "outbounds": [{ "type": "direct" }]
}
EOF
sudo mv /tmp/config.json /etc/sing-box/config.json

# نمایش لینک
echo ""
echo "✅ آماده شد!"
echo ""
echo "🔗 لینک VLESS:"
echo "vless://${UUID}@${DOMAIN}:443?security=tls&flow=xtls-rprx-vision&fp=chrome&type=tcp#G2Ray-Light"
echo ""
echo "📱 این لینک رو در Nekobox یا v2rayNG ایمپورت کن"
echo "⚠️  بعد از استفاده حتما Codespace را Stop کن!"
echo ""

# اجرا
exec sudo /usr/local/bin/sing-box run -c /etc/sing-box/config.json
