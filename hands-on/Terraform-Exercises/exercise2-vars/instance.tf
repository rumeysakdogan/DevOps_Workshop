resource "aws_instance" "rd-inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = var.INSTANCE_TYPE
  availability_zone      = var.ZONE
  vpc_security_group_ids = ["sg-017e962f0ed0cae99"]
  tags = {
    Name    = "First-Instance"
    Project = "20-days-challenge"
  }
}