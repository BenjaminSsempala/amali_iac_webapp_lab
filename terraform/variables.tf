# Input variables: region, instance type, key name, allowed SSH CIDR
variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  type    = string
  default = "terraform-ansible-webapp"
}

variable "ssh_allowed_cidr" {
  description = "Public IP allowed to SSH into the instance"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "Provide a valid CIDR, for example 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "terraform-ansible-webapp-key"
}

variable "ami_ssm_parameter" {
  description = "Public SSM parameter that points at the latest Amazon Linux 2 AMI"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

variable "owner_tag" {
  type    = string
  default = "ssempala_benjamin"
}