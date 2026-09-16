#!/bin/bash

# Save all output to user-data log
exec > /var/log/user-data.log 2>&1

sudo touch /var/log/pathcare-bootstrap.log
sudo chown ubuntu:ubuntu /var/log/pathcare-bootstrap.log

set -euo pipefail
exec > >(tee -a /var/log/pathcare-bootstrap.log) 2>&1

# Update Ubuntu
sudo apt update -y

# Install required packages
sudo apt install -y git curl

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Check Node and npm
node -v
npm -v

# Install pnpm
sudo npm install -g pnpm

# Clone the repository
git clone https://github.com/aman1-2/LabProject01.git /home/ubuntu/project

# Change ownership to ubuntu
sudo chown -R ubuntu:ubuntu /home/ubuntu/project

# Go to project
cd /home/ubuntu/project

# Install dependencies
sudo -u ubuntu pnpm install

# Docker Installation and setup
sudo apt install -y docker.io

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker ubuntu

docker --version

# Redis Setup
 sudo docker rm -f pathcare-redis 2>/dev/null || true

  sudo docker run -d \
    --name pathcare-redis \
    --restart unless-stopped \
    -p 127.0.0.1:6379:6379 \
    redis:7.2-alpine


#Updating the .env files

cat > /home/ubuntu/project/backend/.env <<'EOF'

PORT=5000
NODE_ENV=production
API_PREFIX=/api/v1

CORS_ORIGIN=https://YOUR-VERCEL-DOMAIN.vercel.app

MONGODB_URI=YOUR_MONGODB_URI

REDIS_URL=redis://127.0.0.1:6379

JWT_SECRET=YOUR_JWT_SECRET
JWT_EXPIRES_IN=7d

STORAGE_SIGNING_SECRET=YOUR_STORAGE_SIGNING_SECRET

RAZORPAY_KEY_ID=YOUR_RAZORPAY_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_RAZORPAY_KEY_SECRET
RAZORPAY_WEBHOOK_SECRET=YOUR_RAZORPAY_WEBHOOK_SECRET

AWS_REGION=ap-south-1
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
AWS_S3_BUCKET_NAME=YOUR_S3_BUCKET_NAME

SMS_API_KEY=
SMS_SENDER_ID=PATHCR

WHATSAPP_API_KEY=
WHATSAPP_PHONE_NUMBER_ID=

CANCELLATION_FEE_INR=20
RIDER_SEARCH_RADIUS_KM=5
LAB_VISIT_AUTO_CANCEL_HOURS=8
OTP_TTL_SECONDS=60

RATE_LIMIT_UNAUTH_MAX=100
RATE_LIMIT_UNAUTH_WINDOW_SECONDS=60

RATE_LIMIT_AUTH_MAX=500
RATE_LIMIT_AUTH_WINDOW_SECONDS=60

RATE_LIMIT_OTP_PHONE_MAX=5
RATE_LIMIT_OTP_PHONE_WINDOW_SECONDS=3600

RATE_LIMIT_OTP_IP_MAX=20
RATE_LIMIT_OTP_IP_WINDOW_SECONDS=3600

RATE_LIMIT_LOGIN_MAX=10
RATE_LIMIT_LOGIN_WINDOW_SECONDS=900

TRUST_PROXY_HOPS=1

FF_DYNAMIC_DISPATCH=true
FF_RAZORPAY_AUTO_REFUND=false
FF_PRESCRIPTION_OCR=false
FF_PUSH_NOTIFICATIONS=true
FF_SUBSCRIPTIONS=false

SUBSCRIPTION_ALLOWED_FREQUENCY_DAYS=30,60,90,180,365
SUBSCRIPTION_DEFAULT_FREQUENCY_DAYS=90
SUBSCRIPTION_MAX_CYCLES=24
SUBSCRIPTION_PREDEBIT_NOTICE_HOURS=24
SUBSCRIPTION_PREDEBIT_WINDOW_HOURS=48
SUBSCRIPTION_SWEEP_INTERVAL_MS=3600000

EOF

sudo chown ubuntu:ubuntu /home/ubuntu/project/backend/.env

sudo chmod 600 /home/ubuntu/project/backend/.env

# Install Pm2
sudo npm install -g pm2

# Start Backend with PM2
cd /home/ubuntu/project/backend

sudo -u ubuntu pm2 start src/index.js \
    --name pathcare-api

# Start Worker with PM2
sudo -u ubuntu pm2 start src/worker.js \
    --name pathcare-worker

sudo -u ubuntu pm2 save

sudo -u ubuntu pm2 list

# Start the development server
# sudo -u ubuntu pnpm dev
