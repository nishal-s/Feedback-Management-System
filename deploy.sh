#!/bin/bash
# deploy.sh - Single-Server Provisioning for Jenkins & FeedOps
# Run this ON your existing Jenkins Azure Virtual Machine!

set -e

echo "============================================="
echo " Starting FeedOps Single-VM Provisioning     "
echo "============================================="

# 1. Update and install Python dependencies
echo "=> Updating system and installing Python..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-venv git

# 2. Prepare the Application Directory for Jenkins
echo "=> Setting up /var/www/feedops..."
sudo mkdir -p /var/www/feedops
# Transfer ownership directly to Jenkins so it can pull code later!
if id "jenkins" &>/dev/null; then
    sudo chown -R jenkins:jenkins /var/www/feedops
else
    sudo chown -R $USER:$USER /var/www/feedops
fi
cd /var/www/feedops

# 3. Clone Repository
echo "=> Pulling the latest code..."
REPO_URL="https://github.com/nishal-s/Feedback-Management-System.git"
if [ ! -d ".git" ]; then
    sudo -u jenkins git clone $REPO_URL . || git clone $REPO_URL .
else
    sudo -u jenkins git pull origin main || git pull origin main
fi

# 4. Setup Python Virtual Environment and Install
echo "=> Building Virtual Environment natively..."
sudo -u jenkins python3 -m venv venv || python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. Give Jenkins Sudo access for bouncing the service
# This allows the Jenkinsfile to safely run "sudo systemctl restart feedops" without a password!
echo "=> Granting Jenkins permission to run systemctl..."
echo "jenkins ALL=(ALL) NOPASSWD: /bin/systemctl restart feedops" | sudo tee /etc/sudoers.d/jenkins-feedops > /dev/null
sudo chmod 0440 /etc/sudoers.d/jenkins-feedops

# 6. Create a systemd service to run gunicorn forever 
echo "=> Configuring systemd web service..."
sudo tee /etc/systemd/system/feedops.service > /dev/null <<EOF
[Unit]
Description=Gunicorn daemon serving FeedOps
After=network.target

[Service]
User=jenkins
Group=jenkins
WorkingDirectory=/var/www/feedops
ExecStart=/var/www/feedops/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 7. Enable and Start the Service
echo "=> Starting your application..."
sudo systemctl daemon-reload
sudo systemctl enable feedops
sudo systemctl restart feedops

echo "============================================="
echo " Provisioning successful!"
echo " FeedOps is running locally on Port 8000 alongside Jenkins."
echo "============================================="
