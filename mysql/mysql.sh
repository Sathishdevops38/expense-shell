#!/bin/bash
sudo dnf install mysql-server -y
sudo systemctl enable mysqld
sudo systemctl start mysqld
sudo mysql_secure_installation --set-root-pass ExpenseApp@1