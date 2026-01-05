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
MYSQL_HOST="mysql.daws38sat.fun"

mkdir -p $Logs_Folder
echo "Script started executed at: $(date)" | tee -a $Logs_File

if [ $USER_ID -ne 0 ]
then
    echo -e "$R ERROR: Please run this script with root access $N"
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

sudo dnf module disable nodejs -y
validate $? "Disabling default nodejs"

sudo dnf module enable nodejs:20 -y
validate $? "Enabling nodejs:20 version"

sudo dnf install nodejs -y
validate $? "Installing nodejs"

id expense &>>$Logs_File
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense &>>$Logs_File
    validate $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir /app &>>$Logs_File
if [ $? -ne 0 ]; then
    echo -e "app folder already exists .. $Y SKIPPING$N"
else
    validate $? "Creating app directory"
fi

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "Downloading backend code"

cd /app
validate $? "change tp app dir"

rm -rf /app/*
validate $? "Removing existing code"

sudo unzip /tmp/backend.zip &>> $Logs_File
validate $? "unzipping files"

sudo npm install
validate $? "install dependencies"

sudo tee /etc/systemd/system/backend.service <<EOF
[Unit]
Description = Backend Service
[Service]
User=expense
Environment=DB_HOST= $MYSQL_HOST
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend
[Install]
WantedBy=multi-user.target
EOF
validate $? "creating backend service"

sudo systemctl daemon-reload
validate $? "daemon reload"

sudo systemctl start backend
validate $? "start backend"

sudo systemctl enable backend
validate $? "enabled backend"

sudo dnf install mysql -y
validate $? "install mysql client"

# 1. Check if the 'transactions' database exists
sudo mysql -h "${MYSQL_HOST}" -u root -p'ExpenseApp@1' -e "SHOW DATABASES LIKE 'transactions'" &>>$Logs_File

if [ $? -ne 0 ]; then
    echo -e "Schema not found, loading schema... $Y"
    # 2. Load the schema from the SQL file
    mysql -h "${MYSQL_HOST}" -u root -p'ExpenseApp@1' < /app/schema/backend.sql &>>$Logs_File
    
    # 3. Verify if the load was successful
    if [ $? -eq 0 ]; then
        echo -e "Schema loaded successfully ... $G SUCCESS $N"
    else
        echo -e "Schema load failed ... $R FAILURE $N"
        exit 1
    fi
else
    echo -e "Transactions data is already loaded ... $Y SKIPPING $N"
fi

sudo systemctl restart backend
validate $? "restart backend"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
