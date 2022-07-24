# Hands-on Terraform-03 : Terraform Data Sources, Remote Backend and Provisioners.

Purpose of the this hands-on training is to give students the knowledge of terraform data sources, remote backend and provisioners in Terraform.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Use terraform data sources.
- Create a remote backend.
- Use terraform provisioners.

## Outline

- Part 1 - Terraform Data Sources

- Part 2 - Remote Backend

- Part 3 - Terraform Provisioners

## Part 1 - Terraform Data Sources

- `Data sources` allow data to be fetched or computed for use elsewhere in Terraform configuration.

- Go to the `AWS console and create an image` from your EC2. Select your instance and from actions click image and templates and then give a name for ami `my-ami` and click create. 

# It will take some time. go to the next steps.

- Go to the `variables.tf` file and comment the variable `ec2-ami`.

- Go to the `main.tf` file make the changes in order.

```go
data "aws_ami" "tf_ami" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "tf-ec2" {
  ami           = data.aws_ami.tf_ami.id
  instance_type = var.ec2-type
  key_name      = "mk"
  tags = {
    Name = "${local.mytag}-this is from my-ami"
  }
}
```

```bash
terraform plan
```

```bash
terraform apply
```

- Check EC2 instance's ami id.

- You can see which data sources can be used with a resource in the documentation of terraform. For example EBS snapshot.

```bash
terraform destroy
```

## Part 2 - Terraform Remote State (Remote backend)

- A `backend` in Terraform determines how tfstate file is loaded/stored and how an operation such as apply is executed. This abstraction enables non-local file state storage, remote execution, etc. By default, Terraform uses the "local" backend, which is the normal behavior of Terraform you're used to.

- Go to the AWS console and attach ``DynamoDBFullAccess`` policy to the existing role.

![state-locking](state-locking.png)

- Create a new folder named  `s3-backend` and a file named `backend.tf`. 

```txt
    s3-backend
       └── backend.tf
    terraform-aws
       ├── oliver.tfvars
       ├── main.tf
       └── variables.tf

```

- Go to the `s3-backend` folder and create a file name `backend.tf`. Add the followings.

```bash
cd .. && mkdir s3-backend && cd s3-backend && touch backend.tf
```

```go
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tf-remote-state" {
  bucket = "tf-remote-s3-bucket-james-changehere"

  force_destroy = true # Normally it must be false. Because if we delete s3 mistakenly, we lost all of the states.
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mybackend" {
  bucket = aws_s3_bucket.tf-remote-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_backend_s3" {
  bucket = aws_s3_bucket.tf-remote-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "tf-remote-state-lock" {
  hash_key = "LockID"
  name     = "tf-s3-app-lock"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
```

- Run the commands below.

```bash
terraform init   

terraform apply
```

- We have created a S3 bucket and a Dynamodb table. Now associate S3 bucket with the Dynamodb table.

- Go to the `main.tf` file make the changes.

```go
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
  backend "s3" {
    bucket = "tf-remote-s3-bucket-oliver-changehere"
    key = "env/dev/tf-remote-backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-s3-app-lock"
    encrypt = true
  }
}
```

- Go to the `terraform-aws` directoy and run the commands below. First try to terraform apply command.

```bash
- cd ../terraform-aws
```

```bash
terraform apply  

terraform init  

terraform apply
```

- Because of using S3 bucket for backend, run `terraform init` again. It will ask you to copy the existing tfstate file to s3. yes.

- Go to the AWS console and check the S3 bucket and tfstate file. tfstate file is copied from local to S3 backend.

- Go to the `main.tf` file add the followings and check the versioning on AWS S3 console.

```go
output "s3-arn-1" {
  value = aws_s3_bucket.tf-s3["fredo"].arn
  }
```

```bash
terraform apply
```

- Go to the `main.tf` file make the changes (add another output).

```go
  output "s3-arn-2" {
      value = aws_s3_bucket.tf-s3["santino"].arn
  }
```

- Open a new terminal. Write `terraform apply` in the both terminal. Try to run the command in both terminals at the same time.

- We do not get an error in the terminal that we run `terraform apply` command for the first time, but we get an error in the terminal we run later.

- Now you can try to run the same command with the second terminal. Check the Dynamo DB table and items.

- Destroy all resources. (Run the command in the `terraform-aws` and `s3-backend` folders.)

```bash
terraform destroy   
cd ../s3-backend/
terraform destroy
```

- Do not forget to delete ami and snapshot from the AWS console.

## Part 3 - Terraform Provisioners

- Provisioners can be used to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service.

- The `local-exec` provisioner invokes a local executable after a resource is created. This invokes a process on the machine running Terraform, not on the resource.

- The `remote-exec` provisioner invokes a script on a remote resource after it is created. This can be used to run a configuration management tool, bootstrap into a cluster, etc. To invoke a local process, see the local-exec provisioner instead. The remote-exec provisioner supports both ssh and winrm type connections.

- The `file` provisioner is used to copy files or directories from the machine executing Terraform to the newly created resource. The file provisioner supports both ssh and winrm type connections.

- Most provisioners require access to the remote resource via SSH or WinRM, and expect a nested connection block with details about how to connect. Connection blocks don't take a block label, and can be nested within either a resource or a provisioner.

- The `self` object represents the provisioner's parent resource, and has all of that resource's attributes. For example, use `self.public_ip` to reference an aws_instance's public_ip attribute.

- Take your `pem file` to your local instance's home folder for using `remote-exec` provisioner.

- Go to your local machine and run the following command. 

```bash
scp -i ~/.ssh/<your pem file> <your pem file> ec2-user@<terraform instance public ip>:/home/ec2-user
```

- Or you can drag and drop your pem file to VS Code. Then change permissions of the pem file.

```bash
chmod 400 <your pem file>
```

- Create a folder name `Provisioners` and create a file name `main.tf`. Add the followings.

```bash
$ mkdir Provisioners && cd Provisioners && touch main.tf
```

```go
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance" {
  ami = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name = "oliver"
  security_groups = ["tf-provisioner-sg"]
  tags = {
    Name = "terraform-instance-with-provisioner"
  }

  provisioner "local-exec" {
      command = "echo http://${self.public_ip} > public_ip.txt"
  
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/oliver.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }

  provisioner "file" {
    content = self.public_ip
    destination = "/home/ec2-user/my_public_ip.txt"
  }

}

resource "aws_security_group" "tf-sec-gr" {
  name = "tf-provisioner-sg"
  tags = {
    Name = "tf-provisioner-sg"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }
}
```

- Go to the Provisioners folder and run the terraform file.

```bash
terraform init
terraform apply
```

- Check the resources that created by terraform.

- Terminate the resources.

```bash
$ terraform destroy
```
