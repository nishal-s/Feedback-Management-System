#!/bin/bash
# deploy.sh - Native Python provisioning script for Azure VMs (No Docker!)
# Run this once on your fresh Ubuntu 22.04 Azure Virtual Machine.

set -e

echo "============================================="
echo " Starting FeedOps Native Azure Provisioning  "
echo "============================================="

# 1. Update and install Python dependencies
echo "=> Updating system and installing Python..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-venv git

# 2. Prepare the Application Directory
echo "=> Setting up /var/www/feedops..."
sudo mkdir -p /var/www/feedops
sudo chown $USER:$USER /var/www/feedops
cd /var/www/feedops

# 3. Clone Repository
echo "=> Pulling the latest code..."
REPO_URL="https://github.com/nishal-s/Feedback-Management-System.git"
# If the directory exists but is empty, or doesn't exist, clone it. Otherwise pull.
if [ ! -d ".git" ]; then
    git clone $REPO_URL .
else
    git pull origin main
fi

# 4. Setup Python Virtual Environment and Install
echo "=> Building Virtual Environment natively..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. Create a systemd service to run gunicorn forever 
echo "=> Configuring systemd web service..."
sudo tee /etc/systemd/system/feedops.service > /dev/null <<EOF
[Unit]
Description=Gunicorn daemon serving FeedOps
After=network.target

[Service]
User=$USER
Group=www-data
WorkingDirectory=/var/www/feedops
ExecStart=/var/www/feedops/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 6. Enable and Start the Service
echo "=> Starting your application..."
sudo systemctl daemon-reload
sudo systemctl enable feedops
sudo systemctl restart feedops

echo "============================================="
echo " Provisioning successful!"
echo " FeedOps is running natively on Port 8000 via Gunicorn and Systemd."
echo " To push future updates via Jenkins, the Jenkinsfile is already configured to SSH in and restart this service!"
echo "============================================="
