#!/bin/bash
echo "**********************************************************************************"
echo "
[client]
host=${host}
user=${user}
password=${dbpass}" > ~/.my.cnf

sudo apt update
sudo apt install apache2 mysql-client-core-5.7 -y
sudo mysql --execute quit > /tmp/script.error 2>&1                    

if [ $? -eq 0 ]
then
echo "Connected to DB"  > /var/www/html/index.html
else
echo "Connection failed" > /var/www/html/index.html
fi
