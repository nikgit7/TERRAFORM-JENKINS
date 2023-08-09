resource "aws_vpc" "project-vpc" {
  provider = aws.deployer
  cidr_block = var.cidr_block
  tags = {
    Name = local.vpc
  }
}

resource "aws_subnet" "public" {
  provider = aws.deployer
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = var.cidr_block_public_subnet
  availability_zone = var.availability_zone
  tags = {
    Name        = "public-subnet"
    Environment = local.subnet
  }
}

resource "aws_subnet" "private" {
  provider = aws.deployer
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = var.cidr_block_private_subnet
  availability_zone = var.availability_zone
  tags = {
    Name        = "private-subnet"
    Environment = local.subnet
  }
}

resource "aws_internet_gateway" "ig" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id

  tags = {
    Name = local.ig
  }
}
resource "aws_route_table" "public-rt" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = local.rt
  }
}
resource "aws_route_table_association" "associate" {
  provider = aws.deployer
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_eip" "eipforngw" {
  provider = aws.deployer
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  provider = aws.deployer
  allocation_id = aws_eip.eipforngw.id
  subnet_id = aws_subnet.public.id
  tags = {
    Name = "NatGateway"
  }
}
resource "aws_route_table" "private-rt" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table_association" "associate2" {
  provider = aws.deployer
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private-rt.id
}


resource "aws_key_pair" "ssh_key" {
  provider = aws.deployer
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "web-server-sg" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_instance" "public-ec2" {
  provider = aws.deployer
  ami                         = var.ami_id
  count                       = var.ec2_count
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = var.enable_public_ip
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  tags = {
    Name = local.instance_ws
  }
  

  provisioner "remote-exec" {
    inline = [ 
      "sudo apt install nginx -y",
      "sudo systemctl start nginx"
     ]

     connection {
       type = "ssh"
       user = "ubuntu"
       private_key = file("~/.ssh/id_rsa")
       host = self.public_ip
     }
  }
}

resource "aws_security_group" "frontend-sg" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id
  
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "custom"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.web-server-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "frontend-sg"
  }
}

resource "aws_instance" "frontend-ec2" {
  provider = aws.deployer
  ami                         = var.ami_id
  count                       = var.ec2_count_fe
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.frontend-sg.id]
  tags = {
    Name = local.instance_fe
  }

}

resource "aws_security_group" "backend-sg" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id
  
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "custom"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "backend-sg"
  }
}

resource "aws_instance" "backend-ec2" {
  provider = aws.deployer
  ami                         = var.ami_id
  count                       = var.ec2_count_be
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.backend-sg.id]
  tags = {
    Name = local.instance_be
  }
}

resource "aws_security_group" "mysql-sg" {
  provider = aws.deployer
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "custom"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysql-sg"
  }
}

resource "aws_instance" "mysql-ec2" {
  provider = aws.deployer
  ami                         = var.ami_id
  count                       = var.ec2_count_ms
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.mysql-sg.id]
  tags = {
    Name = local.instance_ms
  }
}

