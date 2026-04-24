terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

}

resource "aws_security_group" "ml_sg" {
  name        = "gguf_endpoint_sg"
  description = "allow ssh for port 8002 for fastAPI and ansible as well"

  ingress {
    description = "ssh incoming port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "fastAPI incoming port"
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ml_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  key_name      = "aws-key"

  vpc_security_group_ids = [aws_security_group.ml_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "gguf-endpoint-instance"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  key_name      = "aws-key"

  vpc_security_group_ids = [aws_security_group.ml_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
                #!/bin/bash
                apt update && apt upgrade -y
                apt install fontconfig openjdk-17-jre ansible -y
                wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
                echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
                apt-get update
                apt-get install jenkins docker.io -y
                usermod -aG docker jenkins
                usermod -aG docker ubuntu
                systemctl restart docker
                systemctl restart jenkins
                EOF

  tags = {
    Name = "jenkins-server"
  }
}

output "instance_ip" {
  description = "aws ec2 instance public ip"
  value       = aws_instance.ml_server.public_ip
}

output "jenkins_ip" {
  description = "aws ec2 jenkins server public ip"
  value       = aws_instance.jenkins_server.public_ip
}