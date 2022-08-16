resource "aws_lb_target_group" "target-group" {
  name     = "awscapstoneTargetGroup"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  health_check {
    path ="/"
    interval = 20
    unhealthy_threshold = 2
    healthy_threshold = 5
  }
  #need to use interpolation to get vpc id from vpc module
  vpc_id   = "vpc-0283d2568c5c3d6f6"
}