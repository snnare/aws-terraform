provider "aws" {
  region = "us-east-2"
  profile = "default"
}

module "my_vpc" {
    source = "./modules/vpc"
    vpc_name = "custom_vpc"
    subnet_name = "custom-public-subnet"
    vpc_cidr = "10.1.0.0/16"
    public_subnet_cidr = "10.1.1.0/24"
    availability_zone = "us-east-2a"
}