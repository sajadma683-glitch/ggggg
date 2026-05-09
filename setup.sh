#!/bin/bash
set -e

echo "🚀 G2Ray-Light Ultra Lite Starting..."

# نصب حداقل وابستگی
apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip uuid-runtime \
    && rm -rf /var/lib/apt/lists/*

# دانلود sing-box (سبک و سریع)
echo "📥 Downloading sing-box..."
SING_VERSION="1.14.0-alpha.21"
curl -L -o /tmp/sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/${SING_VERSION}/sing-box-${SING_VERSION#v}-linux-amd64.tar.gz"
tar -xzf /tmp/sing-box.tar.gz -C /usr/local/bin/
mv /usr/local/bin/sing-box-*/sing-box /usr/local/bin/sing-box
chmod +x /usr/local/bin/sing-box
rm -rf /tmp/sing-box*

# متغیرهای دینامیک
UUID=$(uuidgen)
CODESPACE_NAME=${CODESPACE_NAME:-$(hostname)}
DOMAIN="${CODESPACE_NAME}.github.dev"

echo "🔑 UUID: ${UUID}"
echo "🌐 Domain: ${DOMAIN}"

# کانفیگ خیلی سبک
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
echo "📱 در Nekobox ، v2rayNG یا Clash Meta ایمپورت کن"
echo "⚠️ بعد از استفاده حتما Codespace را Stop کن!"
echo ""

# اجرا
exec /usr/local/bin/sing-box run -c /etc/sing-box/config.json