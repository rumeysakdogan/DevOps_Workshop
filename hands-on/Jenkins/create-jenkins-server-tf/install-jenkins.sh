#! /bin/bash
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum upgrade
amazon-linux-extras install java-openjdk11 -y
amazon-linux-extras install epel -y
yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
systemctl status jenkins
yum install git -y