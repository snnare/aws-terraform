provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-03ea746da1a2e36e7"
  instance_type = "t3.micro"

  tags = {
    Name = "my-first-ec2"
  }
}