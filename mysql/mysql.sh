#!/bin/bash
#install mysql-serer 8.0
sudo dnf install mysql-server -y
#start service
sudo systemctl enable mysqld
#enable mysql
sudo systemctl start mysqld
#set password
sudo mysql_secure_installation --set-root-pass ExpenseApp@1
