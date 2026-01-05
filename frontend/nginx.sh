#!/bin/bash
sudo dnf install nginx -y 
sudo systemctl enable nginx
sudo systemctl start nginx
sudo rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
sudo cd /usr/share/nginx/html
sudo unzip /tmp/frontend.zip
sudo tee /etc/nginx/default.d/expense.conf <<EOF
proxy_http_version 1.1;

location /api/ { proxy_pass http://backend.daws.38sat.fun:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
sudo systemctl restart nginx