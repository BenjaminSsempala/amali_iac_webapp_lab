# Security group (80, 22), key pair and EC2 t2.micro instance (Amazon Linux 2)

# Latest Amazon Linux 2 AMI from the public SSM parameter
data "aws_ssm_parameter" "al2_ami" {
  name = var.ami_ssm_parameter
}

locals {
  private_key_path = abspath("${path.module}/../keys/${var.key_name}.pem")
}

# SSH key pair: generated locally, public half registered with AWS
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

# Private half saved for Ansible
resource "local_sensitive_file" "private_key" {
  content              = tls_private_key.ssh.private_key_openssh
  filename             = local.private_key_path
  file_permission      = "0400"
  directory_permission = "0700"
}

# Security group in the default VPC, allows HTTP from anywhere and SSH from the allowed CIDR
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from the allowed CIDR"
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.al2_ami.insecure_value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  # Require IMDSv2 tokens for the instance metadata service
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt the root disk
  root_block_device {
    encrypted = true
  }

  tags = {
    Name = var.project_name
  }
}
