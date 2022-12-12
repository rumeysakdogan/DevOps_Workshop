resource "aws_key_pair" "dove-key" {
  key_name   = "dovekey"
  public_key = file("dovekey.pub")
}

resource "aws_instance" "dove-inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = var.INSTANCE_TYPE
  availability_zone      = var.ZONE
  key_name               = aws_key_pair.dove-key.key_name
  vpc_security_group_ids = ["sg-017e962f0ed0cae99"]
  tags = {
    Name    = "Dove-Instance"
    Project = "20-days-challenge"
  }

  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }
  
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ip.txt"
    
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }

  connection {
    user        = var.USER
    private_key = file("dovekey")
    host        = self.public_ip
  }
}