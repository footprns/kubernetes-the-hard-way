variable "private_key" {}
variable "certificate_body" {}
variable "certificate_chain" {}

resource "aws_acm_certificate" "default" {
  private_key      = file(var.private_key)
  certificate_body = file(var.certificate_body)
  certificate_chain = file(var.certificate_chain)
}

output "arn" {
    value = aws_acm_certificate.default.arn
}