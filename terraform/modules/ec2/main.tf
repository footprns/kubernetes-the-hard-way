variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
# variable "security_groups" {
#   type = list
# }
variable "vpc_security_group_ids" {
  type = list
}
variable "name" {}
variable "get_password_data" {
  type = bool
}
variable "volume_type" {}
variable "associate_public_ip_address" {
  type = bool
}
variable "subnet_id" {}
variable "private_ip" {}

resource "aws_instance" "default" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  # security_groups = var.security_groups
  vpc_security_group_ids = var.vpc_security_group_ids
  get_password_data = var.get_password_data
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id = var.subnet_id
  private_ip = var.private_ip 
  root_block_device  {
      volume_type = var.volume_type
  }
  tags = {
    Name = "${var.name}"
  }
}

output "public_ip" {
  value = aws_instance.default.public_ip
}

output "password_data" {
  value = aws_instance.default.password_data
}

output "id" {
  value = aws_instance.default.id
}
