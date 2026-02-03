variable "ami" {
    type = string
    description = "AMI ID for the EC2 Instance"
}

variable "instance_type" {
  type = string
  description = "EC2 instance type"
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
  description = "Subnet where  the EC2 Will be deployed"
}


variable "security_group_ids" {
  type = list(string)
  description = "Security groups for the EC2 instance"
}
