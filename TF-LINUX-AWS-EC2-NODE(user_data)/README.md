# This project will create the below resources :

    * Virtual Private Cloud (VPC)
    * Create Public Subnet
    * Create EC2 Key Pair 
    * Create Internet gateway (IGW)
    * Create Route table
    * Route table associations
    * Create Security Group and allow inbound and outbound
    * EC2 instance (Linux)
    * Elastic IP (EIP)

# Providers Used:

    * aws
    * local
    * tls

# Steps:

## Terraform init
![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/dev/TF-LINUX-AWS-EC2-NODE(user_data)/img/terraform_init.png)

## Terraform plan
![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/dev/TF-LINUX-AWS-EC2-NODE(user_data)/img/terraform_plan.png)

## Terraform apply
![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/dev/TF-LINUX-AWS-EC2-NODE(user_data)/img/terraform_apply.png)

## User_data validation (user creation):
![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/dev/TF-LINUX-AWS-EC2-NODE(user_data)/img/user.png)

## User_data validation (Package install (sample chefdk package)):
![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/dev/TF-LINUX-AWS-EC2-NODE(user_data)/img/chefdk.png)

## How to connect linux from Windows machine:

### Step 1: using PuTTY

    Download and install PuTTY for windows from "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"
    Download and install PuTTYgen for windows from "https://www.puttygen.com/"

### Step 2: Generate Private key from .PEM file

![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/TF-LINUX-AWS-EC2-NODE(user_data)/img/PuTTYgen-load.PNG)

![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/TF-LINUX-AWS-EC2-NODE(user_data)/img/PuTTYgen-private.png)

![image](https://raw.githubusercontent.com/Prabhuapr1984/Terraform-AWS/TF-LINUX-AWS-EC2-NODE(user_data)/img/PuTTY-user.png)

![image](https://github.com/Prabhuapr1984/Terraform-AWS/blob/main/TF-LINUX-AWS-EC2-NODE(user_data)/img/PuTTY-auth.PNG)


# Contributors :
- Author:: Prabu Jaganathan ((mailto:Prabhuapr1984@gmail.com))
