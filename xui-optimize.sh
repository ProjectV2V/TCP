#!/bin/bash
set -e

echo "🚀 شروع بهینه‌سازی سرور X-UI..."

# --- 🔧 بهینه‌سازی‌های TCP و کرنل (sysctl) ---
echo "🔧 اعمال تنظیمات بهینه‌سازی TCP و کرنل (sysctl)..."
cat <<EOF >> /etc/sysctl.conf
# X-UI TCP Optimization Settings (added by script)
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.ip_local_port_range = 1024 65000
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
EOF

sysctl -p
echo "✅ تنظیمات TCP و کرنل اعمال شد."

# --- 🔧 افزایش محدودیت‌های File Descriptor (limits.conf) ---
echo "🔧 افزایش محدودیت‌های File Descriptor (limits.conf)..."
cat <<EOF >> /etc/security/limits.conf

# X-UI System-wide File Descriptor Limits (added by script)
* soft nofile 1048576
* hard nofile 1048576
EOF

if ! grep -q "session required pam_limits.so" /etc/pam.d/common-session; then
    echo "session required pam_limits.so" >> /etc/pam.d/common-session
    echo "✅ pam_limits.so به common-session اضافه شد."
else
    echo "ℹ️ pam_limits.so قبلاً وجود داشت."
fi

echo "✅ محدودیت‌های File Descriptor در limits.conf بروزرسانی شد."

# --- 🔧 تنظیم محدودیت‌های Systemd برای سرویس X-UI ---
echo "🔧 تنظیم محدودیت‌های Systemd برای سرویس X-UI..."
SERVICE_NAME="x-ui.service"
mkdir -p "/etc/systemd/system/${SERVICE_NAME}.d"

cat <<EOF > "/etc/systemd/system/${SERVICE_NAME}.d/limits.conf"
[Service]
LimitNOFILE=1048576
EOF

echo "✅ محدودیت‌های Systemd برای ${SERVICE_NAME} تنظیم شد."

# --- 🔄 بارگذاری مجدد Systemd و راه‌اندازی سرویس ---
echo "🔄 بارگذاری مجدد Systemd daemon..."
systemctl daemon-reexec
systemctl daemon-reload

echo "🔁 راه‌اندازی مجدد ${SERVICE_NAME}..."
systemctl restart "$SERVICE_NAME"
systemctl enable "$SERVICE_NAME"

echo "🎉 سرور X-UI با موفقیت بهینه‌سازی شد!"
echo "ℹ️ بررسی وضعیت با: sudo systemctl status ${SERVICE_NAME}"
