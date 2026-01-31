provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-06e3c045d79fd65d9"
  instance_type = "t3.micro"

  tags = {
    Name = "ec2-tf"
  }
}