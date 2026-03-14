#!/bin/bash
# SnapCook Backend Deployment Script
# For Ubuntu 20.04/22.04 LTS

set -e

echo "🚀 Starting SnapCook Backend Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="snapcook-api"
APP_DIR="/opt/snapcook-api"
SERVICE_USER="snapcook"

echo -e "${YELLOW}Step 1: Updating system packages...${NC}"
apt-get update && apt-get upgrade -y

echo -e "${YELLOW}Step 2: Installing Python 3.11...${NC}"
apt-get install -y software-properties-common
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update
apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip

echo -e "${YELLOW}Step 3: Installing system dependencies...${NC}"
apt-get install -y nginx git curl build-essential

# Create service user
echo -e "${YELLOW}Step 4: Creating service user...${NC}"
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/false $SERVICE_USER
fi

# Create application directory
echo -e "${YELLOW}Step 5: Setting up application directory...${NC}"
mkdir -p $APP_DIR
chown $SERVICE_USER:$SERVICE_USER $APP_DIR

# Copy application files (assumes files are in current directory)
echo -e "${YELLOW}Step 6: Copying application files...${NC}"
cp -r . $APP_DIR/
chown -R $SERVICE_USER:$SERVICE_USER $APP_DIR

# Create virtual environment
echo -e "${YELLOW}Step 7: Creating Python virtual environment...${NC}"
cd $APP_DIR
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
echo -e "${YELLOW}Step 8: Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# Create environment file
echo -e "${YELLOW}Step 9: Creating environment file...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${RED}⚠️  Please edit $APP_DIR/.env and add your API keys!${NC}"
    echo -e "${YELLOW}   nano $APP_DIR/.env${NC}"
fi

# Create systemd service
echo -e "${YELLOW}Step 10: Creating systemd service...${NC}"
cat > /etc/systemd/system/$APP_NAME.service << EOF
[Unit]
Description=SnapCook API Service
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
EnvironmentFile=$APP_DIR/.env
ExecStart=$APP_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$APP_NAME

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx
echo -e "${YELLOW}Step 11: Configuring Nginx...${NC}"
cat > /etc/nginx/sites-available/$APP_NAME << 'EOF'
server {
    listen 80;
    server_name _;  # Accept all hostnames/IP addresses

    # Logging
    access_log /var/log/nginx/snapcook-access.log;
    error_log /var/log/nginx/snapcook-error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip compression
    gzip on;
    gzip_types application/json text/plain;

    # API endpoints
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Increase max body size for image uploads
        client_max_body_size 50M;
    }
}
EOF

# Enable Nginx configuration
ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Configure firewall
echo -e "${YELLOW}Step 12: Configuring firewall...${NC}"
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo -e "${YELLOW}Step 13: Starting services...${NC}"
systemctl daemon-reload
systemctl enable $APP_NAME
systemctl enable nginx

# Create management scripts
echo -e "${YELLOW}Step 14: Creating management scripts...${NC}"
cat > /usr/local/bin/snapcook-start << EOF
#!/bin/bash
systemctl start $APP_NAME
echo "SnapCook API started"
EOF

cat > /usr/local/bin/snapcook-stop << EOF
#!/bin/bash
systemctl stop $APP_NAME
echo "SnapCook API stopped"
EOF

cat > /usr/local/bin/snapcook-restart << EOF
#!/bin/bash
systemctl restart $APP_NAME
echo "SnapCook API restarted"
EOF

cat > /usr/local/bin/snapcook-status << EOF
#!/bin/bash
systemctl status $APP_NAME
EOF

cat > /usr/local/bin/snapcook-logs << EOF
#!/bin/bash
journalctl -u $APP_NAME -f
EOF

chmod +x /usr/local/bin/snapcook-*

echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Edit environment variables:"
echo -e "   ${YELLOW}nano $APP_DIR/.env${NC}"
echo ""
echo "   Required variables:"
echo "   - OPENAI_API_KEY"
echo "   - API_KEY (for Flutter app authentication)"
echo ""
echo "2. Start the service:"
echo -e "   ${YELLOW}snapcook-start${NC}"
echo ""
echo "3. Check status:"
echo -e "   ${YELLOW}snapcook-status${NC}"
echo ""
echo "4. View logs:"
echo -e "   ${YELLOW}snapcook-logs${NC}"
echo ""
echo "5. Test the API:"
echo -e "   ${YELLOW}curl http://localhost/health${NC}"
echo -e "   ${YELLOW}curl http://$(curl -s ip.sb)/health${NC}"
echo ""
echo "6. Configure HTTPS (optional but recommended):"
echo -e "   ${YELLOW}certbot --nginx -d your-domain.com${NC}"
echo ""
echo "🔧 Management Commands:"
echo "  - snapcook-start    : Start the service"
echo "  - snapcook-stop     : Stop the service"
echo "  - snapcook-restart  : Restart the service"
echo "  - snapcook-status   : Check service status"
echo "  - snapcook-logs     : View logs"
echo ""
