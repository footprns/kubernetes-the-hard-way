variable "name" {}
variable "egress_rules" {}
variable "ingress_rules" {}
variable "description" {}
variable "vpc_id" {}

resource "aws_security_group" "default" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    description = ingress.value["description"]
    from_port = ingress.value["from_port"]
    to_port = ingress.value["to_port"]
    protocol =  ingress.value["protocol"]
    cidr_blocks = ingress.value["cidr_blocks"]
  }
}

dynamic "egress" {
  for_each = var.egress_rules
  content {
    description = egress.value["description"]
    from_port = egress.value["from_port"]
    to_port = egress.value["to_port"]
    protocol =  egress.value["protocol"]
    cidr_blocks = egress.value["cidr_blocks"]
  }
}

  tags = {
    Name = "allow_ssh_rdp"
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "name" {
  value = aws_security_group.default.name
}
output "id" {
  value = aws_security_group.default.id
}
