#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)
Logs_Folder="/var/log/shell-expense"
Script_Name=$(echo $0 | cut -d "." -f1 | awk -F "/" '{print $NF}')
Logs_File="$Logs_Folder/$Script_Name.log"
START_TIME=$(date +%s)
BACKEND_SERVER="backend.daws38sat.fun"

# Create log folder if not exists
mkdir -p $Logs_Folder

echo "Script started executed at: $(date)" | tee -a $Logs_File

if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERROR$N:: Run the script with root privileges"
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 --- $R Failure $N"
        exit 1
    else
        echo -e "$2 --- $G Success $N"
    fi
}

dnf install nginx -y &>>$Logs_File
validate $? "Installing Nginx"

systemctl enable nginx &>>$Logs_File
validate $? "Enabling Nginx"

systemctl start nginx &>>$Logs_File
validate $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$Logs_File
validate $? "Removing default content"

curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$Logs_File
validate $? "Downloading frontend code"

# Instead of 'sudo cd', we use -d flag with unzip to specify destination
unzip /tmp/frontend.zip -d /usr/share/nginx/html &>>$Logs_File
validate $? "Extracting frontend code"

# Corrected Here-Doc for Nginx Config
tee /etc/nginx/default.d/expense.conf <<EOF
proxy_http_version 1.1;

location /api/ { proxy_pass http://${BACKEND_SERVER}:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
validate $? "Created expense config file"

systemctl restart nginx &>>$Logs_File
validate $? "Restarting Nginx"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"