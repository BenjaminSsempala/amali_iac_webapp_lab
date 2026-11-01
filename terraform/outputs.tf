# Outputs: public IP and DNS, SSH user, key name and private key path

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}

output "ssh_user" {
  description = "Default user on Amazon Linux 2"
  value       = "ec2-user"
}

output "key_name" {
  value = aws_key_pair.web.key_name
}

output "private_key_path" {
  value = local_sensitive_file.private_key.filename
}

output "ssh_command" {
  value = "ssh -i ${local_sensitive_file.private_key.filename} ec2-user@${aws_instance.web.public_ip}"
}

output "web_url" {
  value = "http://${aws_instance.web.public_dns}"
}

output "ansible_inventory" {
  value = <<-EOT
    # EC2 public IP, SSH user and private key
    [web]
    ${aws_instance.web.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=../keys/${aws_key_pair.web.key_name}.pem
  EOT
}
