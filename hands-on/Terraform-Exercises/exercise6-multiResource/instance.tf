resource "aws_key_pair" "dove-key" {
  key_name   = "dovekey"
  public_key = file(var.PUB_KEY)
}

resource "aws_instance" "dove-ec2" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = var.INSTANCE_TYPE
  subnet_id              = aws_subnet.dov-pub-1.id
  key_name               = aws_key_pair.dove-key.key_name
  vpc_security_group_ids = [aws_security_group.dove-stack-sg.id]
  tags = {
    Name = "my-dove"
  }
}

resource "aws_ebs_volume" "vol-4-dove" {
  availability_zone = var.ZONE1
  size              = 3
  tags = {
    Name = "extr-vol-4-dove"
  }
}

resource "aws_volume_attachment" "atch_vol_4_dove" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.vol-4-dove.id
  instance_id = aws_instance.dove-ec2.id
}

output "PublicIP" {
  value = aws_instance.dove-ec2.public_ip
}