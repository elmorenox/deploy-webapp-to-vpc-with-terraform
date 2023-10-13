# 1 VPC
# 2 AZ's
# 2 Public Subnets
# 2 EC2's
# 1 Route Table
# Security Group Ports: 8080, 8000, 22

#VPC
resource "aws_vpc" "retail_bank_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "retail_bank_vpc"
    }
}

# subnets
resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_blocks.0
    availability_zone = var.availability_zone1
    tags = {
        Name = "banking_public_subnet_1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_blocks.1
    availability_zone = var.availability_zone2
    tags = {
        Name = "banking_public_subnet_2"
    }
}

# internet gateway
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "banking_internet_gateway"
    }
}

# gateway <> vpc
resource "aws_vpc_attachment" "gw" {
    vpc_id = aws_vpc.main.id
    internet_gateway_id = aws_internet_gateway.gw.id
}

# route table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "public"
    }
}

# route table <> subnets
resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
    subnet_id = aws_subnet.public2.id
    route_table_id = aws_route_table.public.id
}

# security group
resource "aws_security_group" "security_group" {
    name_prefix = "banking_security_group"
    vpc_id = aws_vpc.main.id

    # outbound
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # inbound
    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "web"
    }
}

# EC2
resource "aws_instance" "web1" {
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.public1.id
    vpc_security_group_ids = [aws_security_group.web.id]
    key_name = var.key_name
    tags = {
        Name = "web1"
    }
}

resource "aws_instance" "web2" {
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.public2.id
    vpc_security_group_ids = [aws_security_group.web.id]
    key_name = var.key_name
    tags = {
        Name = "web2"
    }
}


