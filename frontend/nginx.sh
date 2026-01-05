#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)
Logs_Folder="/var/log/shell-expense"
Script_Name=$(echo $0 | cut -d "." -f1 )
Logs_File="$Logs_Folder/$Script_Name.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
BACKEND_SERVER="backend-dev.daws38sat.fun"

mkdir -p $Logs_Folder
echo "Script started executed at: $(date)" | tee -a $Logs_File

if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERRROR$N:: Run the script with root privillages"
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 --- $R Failure $N"
        exit 1
    else
        echo -e "$2--- $G Success $N"
    fi
}

sudo dnf install nginx -y 
validate $? "Installing Nginx"

sudo systemctl enable nginx
validate $? "Enabling Nginx"

sudo systemctl start nginx
validate $? "Starting Nginx"

sudo rm -rf /usr/share/nginx/html/*
validate $? "Removing default content"

curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate $? "Downloading frontend code"

sudo cd /usr/share/nginx/html
validate $? "Moving to app location"

sudo unzip /tmp/frontend.zip &>> $Logs_File
validate $? "Extracting frontend code"

sudo tee /etc/nginx/default.d/expense.conf <<EOF
proxy_http_version 1.1;

location /api/ { proxy_pass http://$BACKEND_SEREVR:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
validate $? "created expense conf file"

sudo systemctl restart nginx
validate $? "Restarting Nginx"
END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"