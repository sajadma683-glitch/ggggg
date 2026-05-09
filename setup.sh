#!/bin/bash
set -e

echo "🚀 G2Ray-Light Ultra Lite Starting..."

# نصب با sudo
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    ca-certificates curl unzip uuid-runtime \
    && sudo rm -rf /var/lib/apt/lists/*

# دانلود sing-box (نسخه پایدار)
echo "📥 Downloading sing-box..."
curl -L -o /tmp/sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v1.13.11/sing-box-1.13.11-linux-amd64.tar.gz"

tar -xzf /tmp/sing-box.tar.gz -C /usr/local/bin/
mv /usr/local/bin/sing-box-1.13.11-linux-amd64/sing-box /usr/local/bin/sing-box
chmod +x /usr/local/bin/sing-box
rm -rf /tmp/sing-box*

# متغیرهای دینامیک
UUID=$(uuidgen)
CODESPACE_NAME=${CODESPACE_NAME:-$(hostname)}
DOMAIN="${CODESPACE_NAME}.github.dev"

echo "🔑 UUID: ${UUID}"
echo "🌐 Domain: ${DOMAIN}"

# کانفیگ
mkdir -p /etc/sing-box
cat > /etc/sing-box/config.json << EOF
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

# نمایش لینک
echo ""
echo "✅ آماده شد!"
echo ""
echo "🔗 لینک VLESS:"
echo "vless://${UUID}@${DOMAIN}:443?security=tls&flow=xtls-rprx-vision&fp=chrome&type=tcp#G2Ray-Light"
echo ""
echo "📱 در Nekobox یا v2rayNG ایمپورت کن"
echo "⚠️ بعد از استفاده حتما Codespace را Stop کن!"
echo ""

# اجرا
exec /usr/local/bin/sing-box run -c /etc/sing-box/config.json
