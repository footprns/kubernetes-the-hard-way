variable "key_name" {}
variable "public_key" {}


resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = var.public_key
}

output "key_pair_id" {
  value = aws_key_pair.default.key_pair_id
}

output "key_name" {
  value = aws_key_pair.default.key_name
}
