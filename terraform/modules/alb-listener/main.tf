variable "name" {}
# variable "certificate_arn" {}
variable "load_balancer_arn" {}


resource "aws_lb_listener" "default" {
  load_balancer_arn = var.load_balancer_arn
  port              = "6443"
  protocol          = "TCP"
  # protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_target_group" "default" {
  name     = var.name
  port     = 6443
  protocol = "TCP"
  vpc_id   = "vpc-4cc2dd2b"
/*
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    # timeout             = 5
    protocol = "HTTP"
    port = "6443"
    path = "/version"
    interval            = 30
    # matcher = "200"
  }
*/
}

output "arn" {
  value = aws_lb_target_group.default.arn
}
