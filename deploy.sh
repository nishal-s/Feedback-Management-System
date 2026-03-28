#!/bin/bash
# automated-deploy.sh - Run this on your fresh Azure Ubuntu Virtual Machine!

set -e

echo "============================================="
echo " Starting FeedOps Azure VM Deployment Script"
echo "============================================="

# 1. Update the system
echo "=> Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Install Git and dependencies
echo "=> Installing Git..."
sudo apt-get install git -y

# 3. Install Docker and Docker-Compose
echo "=> Installing Docker suite..."
sudo apt-get install docker.io docker-compose -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# 4. Clone the repository
echo "=> Cloning repository..."
REPO_URL="https://github.com/nishal-s/Feedback-Management-System.git"
git clone $REPO_URL feedops-app || echo "Directory exists, skipping clone"

# 5. Bring up the application with Docker
echo "=> Building and starting the container..."
cd feedops-app
# Stop existing containers if we are updating
sudo docker-compose down || true
# Rebuild and run detached
sudo docker-compose up -d --build

echo "============================================="
echo " Deployment successful!"
echo " Your app is now running on Port 8000."
echo " To allow public internet access, ensure you have:"
echo "   1. Opened Port 8000 in your Azure Network Security Group (NSG) inbound port rules."
echo "   2. Navigated to http://<YOUR_AZURE_PUBLIC_IP>:8000"
echo "============================================="
