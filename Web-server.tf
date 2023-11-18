#Always first Define the provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}


/*Create a VPC(Virtual Private Cloud) its an isolated environment in the AWS public cloud 
which is seperating our resource from the outside environment, it will become our 
LAN(local area network) within the internet*/
resource "aws_vpc" "my-web-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "my-vpc"
    }
}



#Create an Internet Gateway - which connects our VPC to the Internet
resource "aws_internet_gateway" "my-IGW" {
  vpc_id = aws_vpc.my-web-vpc.id

  tags = {
    Name = "my-web-igw"
  }
}



#Create a Route Table and associate it with our IGW
resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.my-web-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-IGW.id 
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.my-IGW.id  
  }

  tags = {
    Name = "web-route"
  }
}



#Create a Subnet in the same region as your VPC and in any availability zone like 1a, 1b, 1c or else the VPC and Subnet will not be able to connect it will throw a error.
resource "aws_subnet" "Public-Subnet1" {
    vpc_id = aws_vpc.my-web-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "my-subnet"
    }
}



#Associating our Subnet with Route Table
resource "aws_route_table_association" "my-web-route1" {
  subnet_id      = aws_subnet.Public-Subnet1.id
  route_table_id = aws_route_table.my-route.id
}





#Creating a Security Group to allow only port 22(SSH), 80(HTTP), 443(HTTPS).
resource "aws_security_group" "allow_web-server" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my-web-vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "HTTP from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-web-sg"
  }
}




#Create a Network Interface with an IP in the subnet that was created in our Public-Subnet1
resource "aws_network_interface" "my-nic" {
  subnet_id       = aws_subnet.Public-Subnet1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web-server.id]
}




#Now assign a Elatic IP to the network Interface that we created before 
#An Elastic IP is nothing but a "Static Public IP Address" where we asign it to our Web Server if we need an IP address that does not change when we start and stop our Instance. 
#EIP may require IGW to exist prior to association. Use depends_on to set an explicit dependency on the IGW.(Go Through the Terraform Documentation)  
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.my-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.my-IGW] 
}





#Now Creating our Linux server and then install and enable Apache HTTPD
resource "aws_instance" "My-Web-Server" {
    ami = "ami-0230bd60aa48260c6"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "myWeb"

  tags ={
        Name = "my-web-server"
    }         


    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.my-nic.id
       }
       
#Here we provide User Data which is the set of command/data we can provide to a instance during the launch time.       
#Here we use "<<-EOF" to start and "EOF" to end, which basically allows us to create multiline strings without having to insert \n characters all over the place. 
     user_data = <<-EOF
                  #!/bin/bash
                  sudo yum update -y
                  sudo yum install httpd -y
                  sudo systemctl start httpd
                  EOF  
}  
