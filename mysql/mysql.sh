#!/bin/bash
#install mysql-serer 8.0
dnf install mysql-server -y
#start service
sudo systemctl start mysqld
#enable mysql
sudo systemctl enable mysqld
#set password
sudo mysql_secure_installation --set-root-pass ExpenseApp@1
