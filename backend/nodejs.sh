#!/bin/bash
#disable default node version
sudo dnf module disable nodejs -y
#enable node 20 version
sudo dnf module enable nodejs:20 -y
#install nodejs
sudo dnf install nodejs -y

#useradd
sudo useradd expense
#create dir
sudo mkdir /app
curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
cd /app
sudo unzip /tmp/backend.zip
sudo npm install
#create service file
sudo cp ./service.repo /etc/systemd/system/backend.service
#demon-reload
sudo systemctl daemon-reload
#start service
sudo systemctl start backend
#enable service
sudo systemctl enable backend

#install mysql
sudo dnf install mysql -y

#Load Schema
sudo mysql -h 172.31.23.108 -uroot -pExpenseApp@1 < /app/schema/backend.sql