resource "aws_security_group" "dove-stack-sg" {
  name        = "dove-stack-sg"
  description = "Secgrp for dove SSH"
  vpc_id      = aws_vpc.dove.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MyIP]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}