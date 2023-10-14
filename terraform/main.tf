# 1 VPC
# 2 AZ's
# 2 Public Subnets
# 2 EC2's
# 1 Route Table
# Security Group Ports: 8080, 8000, 22

#VPC
resource "aws_vpc" "retail_bank_vpc" {
    cidr_block = var.vpc_cidr_block

    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "retail_bank_vpc"
    }
}

# internet gateway
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.retail_bank_vpc.id
    tags = {
        Name = "banking_internet_gateway"
    }
}


# subnets
resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.retail_bank_vpc.id
    cidr_block = var.public_subnet_cidr_blocks.0
    availability_zone = var.availability_zone1
    tags = {
        Name = "banking_public_subnet_1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.retail_bank_vpc.id
    cidr_block = var.public_subnet_cidr_blocks.1
    availability_zone = var.availability_zone2
    tags = {
        Name = "banking_public_subnet_2"
    }
}

# route table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.retail_bank_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "public"
    }
}

# route table <> subnets
resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "banking_security_group" {
    name_prefix = "web_"
    vpc_id = aws_vpc.retail_bank_vpc.id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "banking_security_group"
    }
}

# EC2s
resource "aws_instance" "web_server" {
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.public_subnet_2.id
    vpc_security_group_ids = [aws_security_group.banking_security_group.id]
    key_name = var.key_name
    associate_public_ip_address = true
    user_data=("webserver-dependencies.sh")
    tags = {
        Name = "web_server"
    }
}

resource "aws_instance" "jenkins_server" {
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.public_subnet_1.id
    vpc_security_group_ids = [aws_security_group.banking_security_group.id]
    key_name = var.key_name
    associate_public_ip_address = true
    user_data = templatefile("jenkins-deploy.sh", {
        jenkinspwd=var.jenkinspwd,
    })
    tags = {
        Name = "jenkins_server"
    }
}

output "instance_ips" {
  value = [aws_instance.jenkins_server.public_ip, aws_instance.web_server.public_ip]
}