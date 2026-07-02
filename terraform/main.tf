terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Verifique se o seu Learner Lab roda nesta região
}

# Busca a imagem mais recente do Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Grupo de Segurança para liberar portas essenciais
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-cluster-sg"
  description = "Liberar portas K3s, SSH, HTTP e HTTPS"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Frontend)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API do Kubernetes (Control Plane)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Comunicação interna dos nós do cluster
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criando o Control Plane
resource "aws_instance" "control_plane" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.medium" 
  key_name        = "vockey"    
  security_groups = [aws_security_group.k3s_sg.name]

  tags = {
    Name = "DevOps-ControlPlane"
    Role = "master"
  }

  # ADICIONE ESTE BLOCO AQUI:
  lifecycle {
    ignore_changes = [ami]
  }
}

# Criando os 3 Nós de Trabalho
resource "aws_instance" "workers" {
  count           = 3
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro" 
  key_name        = "vockey"
  security_groups = [aws_security_group.k3s_sg.name]

  tags = {
    Name = "DevOps-Worker-${count.index + 1}"
    Role = "worker"
  }

  # ADICIONE ESTE BLOCO AQUI TAMBÉM:
  lifecycle {
    ignore_changes = [ami]
  }
}

# Exibir os IPs gerados no final da execução
output "control_plane_ip" {
  value = aws_instance.control_plane.public_ip
}

output "workers_ips" {
  value = aws_instance.workers[*].public_ip
}