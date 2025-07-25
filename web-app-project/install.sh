#!/bin/bash
sudo apt update -y
sudo apt install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from Terraform" > /var/www/html/index.html