#!/bin/bash
sudo dnf module disable nodejs -y
sudo dnf module enable nodejs:20 -y
sudo dnf install nodejs -y
sudo useradd expense
sudo mkdir /app
curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
cd /app
sudo unzip /tmp/backend.zip
sudo npm install
sudo tee /etc/systemd/system/backend.service <<EOF
[Unit]
Description = Backend Service
[Service]
User=expense
Environment=DB_HOST="mysql.daws38sat.fun"
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start backend
sudo systemctl enable backend
sudo dnf install mysql -y
sudo mysql -h mysql.daws38sat.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql
sudo systemctl restart backend
