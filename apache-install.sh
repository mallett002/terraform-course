#!/bin/bash
# yum update -y
# yum install httpd -y
# service httpd start
# cd /var/www/html
# echo "<html><body><h1>WebServer 1 in Northern VA</h1></body></html>" > index.html
sudo apt update
sudo apt install apache2
sudo mkdir /var/www/
cd /var/www/
echo "<html><body><h1>My name is Billy</h1></body></html>" > index.html
