# EC2 Auto Scaling and Load Balancing on AWS using Terraform

This repository contains Terraform code to provision a complete EC2 Auto Scaling infrastructure with an Application Load Balancer (ALB) on AWS. It includes:

- Launch Template
- Auto Scaling Group (ASG)
- Application Load Balancer
- Target Group and Listener
- Security Groups
- VPC, Subnets, and other necessary components

## 📌 Architecture Overview

     +-----------------------------+
     |     Route 53 / DNS         |
     +--------------+-------------+
                    |
                    v
      +----------------------------+
      |   Application Load Balancer|
      +----------------------------+
                 |
      +----------+----------+
      |                     |
 EC2 Instance 1       EC2 Instance 2  ... (via Auto Scaling Group)

 
---

## 📁 Project Structure

```bash
web-app-project/
  ├── ec2.tf                 # Launch Template, Security Groups, Load Balancer, Target Group, Auto Scaling Group and policies for EC2
  ├── user_data.sh           # EC2 instance bootstrap script
  ├── variables.tf           # Input variables
  ├── vpc.tf                 # VPC, Subnets, Internet Gateway, Route Tables
├── main.tf                  # Root Terraform config
├── output.tf                # Output values
├── providers.tf             # Security Groups
```

## ⚙️ Prerequisites
Terraform >= 1.3

AWS CLI configured (aws configure)

An existing key pair in AWS (or update the code to create a new one)

## 🚀 How to Use
### 1. Clone the Repository
```
git clone https://github.com/yourusername/ec2-autoscaling-terraform.git   
cd ec2-autoscaling-terraform
```
### 2. Initialize Terraform
```
terraform init
```
### 3. Plan the Deployment
```
terraform plan
```
### 4. Apply the Configuration
```
terraform apply
```
Confirm with yes when prompted.

## 📤 Outputs
After applying, Terraform will output:

- Load Balancer DNS name
- Auto Scaling Group name
- Public subnets used
- Security group IDs

## 📜 Sample User Data
EC2 instances can use user_data.sh to install and run a simple web server:

```
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
echo "Hello from Auto Scaling Group Instance" > /var/www/html/index.html
```

## 🛑 Destroy Infrastructure
To tear down all resources:

```
terraform destroy
```

## 🧠 Concepts Covered
- Auto Scaling Groups (ASG)
- Launch Templates
- Application Load Balancer (ALB)
- Target Groups
- Listeners
- VPC & Subnets (public)
- Security Groups
- EC2 Bootstrap with user_data

## 📌 Notes
Resources are deployed in default or specified AWS region.
Make sure your IAM user/role has permission to create the resources.
Ensure the VPC and subnet CIDR blocks don’t conflict with existing ones.

🙌 Acknowledgements
Terraform AWS Provider Docs
AWS Documentation

