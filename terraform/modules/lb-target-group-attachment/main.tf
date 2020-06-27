variable "target_group_arn" {}
variable "target_id" {}
variable "port" {}

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = var.target_group_arn
  target_id        = var.target_id
  port             = var.port
}