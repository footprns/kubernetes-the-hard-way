variable "name" {}
# variable "security_groups" {
#   type = list
# }
variable "load_balancer_type" {}


resource "aws_lb" "default" {
  name               = var.name
  internal           = false
  load_balancer_type = var.load_balancer_type
  # security_groups    = var.security_groups
  subnets            = ["subnet-cab073ac", "subnet-445cac0c", "subnet-6b07b832"]

  enable_deletion_protection = false

#   access_logs {
#     bucket  = "${aws_s3_bucket.lb_logs.bucket}"
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "${var.name}"
  }
}

output "arn" {
  value = aws_lb.default.arn
}
