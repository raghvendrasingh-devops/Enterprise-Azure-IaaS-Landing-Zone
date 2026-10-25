#!/usr/bin/env bash
# ===================================================================================
# ENTERPRISE IAAS VMSS BOOTSTRAP & HARDENING SCRIPT
# Author: Raghvendra Singh | Lead DevSecOps Architect
# Target OS: Ubuntu 22.04 LTS Gen2
# ===================================================================================

set -euo pipefail

echo "=========================================="
echo "Starting Enterprise VMSS Hardening Bootstrap"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "=========================================="

# 1. Linux Kernel & Network Stack Hardening (CIS Benchmark)
cat << 'EOF' > /etc/sysctl.d/99-cis-hardening.conf
# Disable IP packet forwarding
net.ipv4.ip_forward = 0
# Ignore ICMP echo broadcasts
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
# Enable TCP SYN cookies for SYN flood mitigation
net.ipv4.tcp_syncookies = 1
# Log Martian Packets (spoofed packets)
net.ipv4.conf.all.log_martians = 1
# Memory management
vm.swappiness = 10
EOF

sysctl --system

# 2. Package Updates & Core Security Utilities
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
    curl \
    wget \
    jq \
    ufw \
    fail2ban \
    nginx \
    unzip \
    ca-certificates

# 3. Secure Nginx Application Reverse Proxy Setup
cat << 'EOF' > /var/www/html/health
{"status":"UP","node":"VMSS_NODE","timestamp":"OK"}
EOF

cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    # Security Headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    location /health {
        root /var/www/html;
        access_log off;
        default_type application/json;
    }

    location / {
        return 200 '{"message":"Enterprise IaaS Application Tier Online","tier":"Tier-2 App"}';
        add_header Content-Type application/json;
    }
}
EOF

nginx -t
systemctl restart nginx
systemctl enable nginx

# 4. Host-based Firewall (UFW) Hardening
ufw default deny incoming
ufw default allow outgoing
ufw allow 80/tcp comment 'Allow HTTP from Internal Load Balancer'
ufw allow 443/tcp comment 'Allow HTTPS'
ufw --force enable

echo "=========================================="
echo "Bootstrap Completed Successfully!"
echo "=========================================="
