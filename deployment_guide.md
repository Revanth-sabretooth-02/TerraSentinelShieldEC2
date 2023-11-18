  # A secure EC2 Instance Deployment using Terraform

This repository provides Terraform configurations to automate the deployment of an EC2 instance within a custom Virtual Private Cloud (VPC) on AWS. The setup restricts access to SSH and includes automatic installation of an Apache HTTP Server to handle web traffic.

## Deployment Steps

### Steps

1. **Create a VPC**
   - Use Terraform to define and configure a Virtual Private Cloud (VPC) a VPC(Virtual Private Cloud) its an isolated environment in the AWS public cloud 
     which is seperating our resource from the outside environment, it will become our LAN(local area network) within the internet.
     Specify its CIDR block and essential settings.

2. **Create an Internet Gateway**
   - Establish an Internet Gateway via Terraform and associate it with the VPC to enable internet access for resources within the VPC.
   - which connects our VPC to the Internet

3. **Create a Custom Route Table**
   - Define a custom route table within the VPC using Terraform and associate it with our IGW.

4. **Create a Subnet**
   - Create a Subnet in the same region as your VPC and in any availability zone like 1a, 1b, 1c or else the VPC and Subnet will not be able to connect it will throw an error.
   -  Define its CIDR block and specify other relevant subnet details.

5. **Associate Subnet with Route Table**
   - Associate the created subnet with the custom route table to manage network traffic effectively.

6. **Create Security Group for SSH, HTTP and HTTPS**
   - Configure a security group via Terraform that allows inbound traffic on port 22 (SSH), port 80 (HTTP) and 443 (HTTPS).
   - Here we are only Creating a Security Group to allow only port 22(SSH), 80(HTTP), 443(HTTPS)

7. **Create a Network Interface in the Subnet**
   - Create a Network Interface with an IP in the subnet that was created in our Public-Subnet1 to specify an IP address within the subnet for the interface.

8. **Assign an Elastic IP to the Network Interface**
   - Now assign a Elatic IP to the network Interface that we created before.
   - An Elastic IP is nothing but a "Static Public IP Address" where we asign it to our Web Server if we need an IP address that does not change when we start and stop our Instance. 

9. **Create Linux Server, Install, and Enable Apache httpd**
   - Utilize Terraform to provision an EC2 instance. Choose an appropriate Linux AMI, create an instance in the previously defined subnet, and configure the instance to install and enable Apache HTTP Server.
   - A NOTE : Terraform does not care about the order in which you write your code because Terraform is Intelligent enough to figure out what needs to be created first,
     but EIP may require IGW to exist prior to association. Here terraform needs a proper order to create an elastic IP where it needs the Internet Gateway to exist first, or else terraform will thrwo error. It only happens in some rare cases

### Additional Notes
- **SSH Configuration:**
  - Configure SSH access to the EC2 instance using the key pair through Terraform or manually.
  - Create Key Pair in .pem or .ppk where if you use .pem you can use clients like Mobaxterm, Cloud, Command Prompt and if use .ppk you should have putty installed also you can convert .pem into .ppk in putty.
  - Adjust security group settings to permit SSH access (port 22) only from trusted IP addresses.

Feel free to modify the Terraform scripts provided here to suit your specific project requirements.

## Author
Revanth P
