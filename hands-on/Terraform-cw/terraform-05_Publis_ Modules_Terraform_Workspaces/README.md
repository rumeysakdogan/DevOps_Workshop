# Hands-on Terraform-05: Publishing Modules and Terraform Workspaces

Purpose of the this hands-on training is to give students the knowledge of publishing modules and using workspaces in Terraform.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Publish Terraform Modules

- Use Terraform Workspaces

## Outline

- Part 1 - Publish Terraform Modules

- Part 2 - Use Terraform Workspaces

## Part 1 - Publish Terraform Modules

- Anyone can publish and share modules on the Terraform Registry.

- Published modules support versioning, automatically generate documentation, allow browsing version histories, show examples and READMEs, and more. Terraform recommend publishing reusable modules to a registry.

- Public modules are managed via ``Git`` and ``GitHub``. Once a module is published, you can release a new version of a module by simply pushing a properly formed Git tag.

### Requirements

- The list below contains all the requirements for publishing a module:

* ``GitHub``. The module must be on GitHub and must be a ``public`` repo. This is only a requirement for the public registry. If you're using a private registry, you may ignore this requirement.

* ``Named terraform``-<PROVIDER>-<NAME>. Module repositories must use this three-part name format, where <NAME> reflects the type of infrastructure the module manages and <PROVIDER> is the main provider where it creates that infrastructure. The <NAME> segment can contain additional hyphens. Examples: terraform-google-vault or terraform-aws-ec2-instance.

* ``Repository description``. The GitHub repository description is used to populate the short description of the module. This should be a simple one sentence description of the module.

* ``Standard module structure``. The module must adhere to the standard module structure. This allows the registry to inspect your module and generate documentation, track resource usage, parse submodules and examples, and more.

* ``x.y.z tags for releases``. The registry uses tags to identify module versions. Release tag names must be a semantic version, which can optionally be prefixed with a v. For example, v1.0.4 and 0.9.2. To publish a module initially, at least one release tag must be present. Tags that don't look like version numbers are ignored. (https://semver.org/)

- source link: https://www.terraform.io/registry/modules/publish

### Create a module to create an aws instance with amazon linux 2 ami (kernel 5.10).

- Create a directory for modules to publish.

```bash
cd && mkdir clarusway-modules && cd clarusway-modules && touch main.tf variables.tf outputs.tf versions.tf userdata.sh README.md .gitignore
```

- Go to the `versions.tf` and copy the latest provider version from the terraform documentaion (https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

```go
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

- Go to the `variables.tf` and prepare your modules variables.

```go
variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "num_of_instance" {
  type = number
  default = 1
}

variable "tag" {
  type = string
  default = "Docker-Instance"
}

variable "server-name" {
  type = string
  default = "docker-instance"
}

variable "docker-instance-ports" {
  type = list(number)
  description = "docker-instance-sec-gr-inbound-rules"
  default = [22, 80, 8080]
}
```

- Go to the `main.tf` and prepare a config file to create an aws intance with amazon linux 2 ami (kernel 5.10).

```go
data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

data "template_file" "userdata" {
  template = file("${abspath(path.module)}/userdata.sh")
  vars = {
    server-name = var.server-name
  }
}

resource "aws_instance" "tfmyec2" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  count = var.num_of_instance
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  user_data = data.template_file.userdata.rendered
  tags = {
    Name = var.tag
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = "${var.tag}-terraform-sec-grp"
  tags = {
    Name = var.tag
  }

  dynamic "ingress" {
    for_each = var.docker-instance-ports
    iterator = port
    content {
      from_port = port.value
      to_port = port.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port =0
    protocol = "-1"
    to_port =0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

- Go to the `outputs.tf` and write some outputs.

```go
output "instance_public_ip" {
  value = aws_instance.tfmyec2.*.public_ip
}

output "sec_gr_id" {
  value = aws_security_group.tf-sec-gr.id
}

output "instance_id" {
  value = aws_instance.tfmyec2.*.id
}
```

- Go to the `userdata.sh` file and write the followings.

```bash
#!/bin/bash
hostnamectl set-hostname ${server-name}
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

- Go to the `.gitignore` file and write the followings. 

```bash
# Local .terraform directories
**/.terraform/*

# Terraform lockfile
.terraform.lock.hcl

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude all .tfvars files, which are likely to contain sentitive data, such as
# password, private keys, and other secrets. These should not be part of version
# control as they are data points which are potentially sensitive and subject
# to change depending on the environment.
*.tfvars

```

- Go to the `README.md` and make a description of your module.

---
Terraform Module to provision an AWS EC2 instance with the latest amazon linux 2 ami and installed docker in it.

Not intended for production use. It is an example module.

It is just for showing how to create a publish module in Terraform Registry.

Usage:

```hcl

provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
    source = "<github-username>/docker-instance/aws"
    key_name = "clarusway"
}
```
---

### Create a Github repository for our terraform module

- Create a `public` github repo and name it as `terraform-aws-docker-instance`.

- Clone the repository to your local.

```bash
git clone https://github.com/<your-github-account>/terraform-aws-docker-instance.git
```

- ``Copy`` the module files to this repository folder.

- Next, ``push`` the files to github repo and give a tag to version our module. You should give a semantic version to your module.(https://semver.org/)

```bash
git add .
git commit -m "should define your key file"
git push
git tag v0.0.1
git push --tags
```

- Go to the `Terraform Registry` and sign in with your `Github Account`.

- Next, `Publish` your module.

* Terraform Registry --> Sign in --> Github account --> Publish --> Modules --> Select the module repo in Github (terraform-aws-docker-instance) --> Click Agree in Terms --> Publish Module

- Go to the ``Github Repository``. Define a description in `About` part in github repository. (Click settings wheel)

```yml
- Description: Terraform module which creates a docker instance resource on AWS.

- Website: https://registry.terraform.io/modules/<account>/docker-instance/aws/latest
```

### Create an EC2 instance on AWS that installed docker with your public module.

- Create a terraform config file to create an aws instance on AWS.

```bash
cd && mkdir cw-modules && cd cw-modules && touch main.tf
```

- Go to the the module page in `Terraform Registry`.

- Copy `Provision Instructions` or `Usage` part. Next, paste it to the `main.tf` and add your `key file` name.

```go
provider "aws" {
  region = "us-east-1"
}

module "docker-instance" {
  source  = "clarusway/docker-instance/aws"
  key_name = "clarusway"
}
```

- Run terraform file.

```bash
terraform init

terraform apply --auto-approve
```

- After checking the instance, you can terminate it.

```bash
terraform destroy --auto-approve
```

## Part 2 - Terraform Workspaces

### When to use Multiple Workspaces

- Terraform relies on state to associate resources with real-world objects, so if you run the same configuration multiple times with completely separate state data, Terraform can manage many non-overlapping groups of resources. In some cases you'll want to change variable values for these different resource collections (like when specifying differences between staging and production deployments), and in other cases you might just want many instances of a particular infrastructure pattern.

- The simplest way to maintain multiple instances of a configuration with completely separate state data is to use multiple working directories.

- `Workspaces` allow you to use the same working copy of your configuration and the same plugin and module caches, while still keeping separate states for each collection of resources you manage.

- Every initialized working directory has at least one workspace. (If you haven't created other workspaces, it is a workspace named ``default``.)

- For a given working directory, only one workspace can be selected at a time.

- A common use for multiple workspaces is to create a parallel, distinct copy of a set of infrastructure in order to test a set of changes before modifying the main production infrastructure. For example, a developer working on a complex set of infrastructure changes might create a new temporary workspace in order to freely experiment with changes without affecting the default workspace.

### Using Workspaces

- Create a directory name `workspaces` to learn terraform workspaces. Next create terraform config file name `workspace.tf`.

```bash
cd && mkdir workspaces && cd workspaces && touch workspace.tf
```

- Add the followings.

```go
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tfmyec2" {
  ami = lookup(var.myami, terraform.workspace)
  instance_type = "${terraform.workspace == "dev" ? "t3a.medium" : "t2.micro"}"
  count = "${terraform.workspace == "prod" ? 3 : 1}"
  key_name = "<your-pem-file>"
  tags = {
    Name = "${terraform.workspace}-server"
  }
}

variable "myami" {
  type = map(string)
  default = {
    default = "ami-0cff7528ff583bf9a"
    dev     = "ami-06640050dc3f556bb"
    prod    = "ami-08d4ac5b634553e16"
  }
  description = "in order of aAmazon Linux 2 ami, Red Hat Enterprise Linux 8 ami and Ubuntu Server 20.04 LTS amis"
}
```

- Workspaces are managed with the ``terraform workspace`` set of commands. We can see the command options with `--help` flag.

```bash
terraform workspace --help
terraform workspace list
terraform workspace show
```

- Create two workspaces with names `dev` and `prod`.

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace list
terraform workspace show
terraform workspace select dev
```

- After creating namespaces, terraform creates new folders for new workspaces. Check the `workspace` folder and see the new folders.(`terraform.tfstate.d`)

- Run the following terraform commands to create instances in `dev` and `default` workspaces.

```bash
terraform init
terraform plan

terraform workspace select prod
terraform workspace show
terraform plan
# check the plan's "instance_type", "ami", "number of instances" and "tag" parts.

terraform workspace select dev
terraform workspace show
terraform apply --auto-approve
# check "./workspaces/terrafor.tfstate.d/dev" folder. Terraform was created "terraform.tfstate" file in that folder. 
terraform destroy --auto-approve

terraform workspace select default
terraform workspace show
terraform apply --auto-approve
# Terraform was created "terraform.tfstate" file in root folder for the "default" workspace.
terraform destroy --auto-approve
```

- ``Delete`` the workspaces.

```bash
terraform workspace list
terraform workspace show
terraform workspace delete prod
terraform workspace delete dev
# terraform deletes workspaces and their folders included their "state" files. 
```