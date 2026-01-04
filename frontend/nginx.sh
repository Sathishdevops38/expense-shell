#!/bin/bash
#install nginx
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
#remove default nginx content
sudo rm -rf /usr/share/nginx/html/*
#download fronend content
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
cd /usr/share/nginx/html
sudo unzip /tmp/frontend.zip
#service
sudo cp ./front.repo /etc/nginx/default.d/expense.conf
suod systemctl restart nginx