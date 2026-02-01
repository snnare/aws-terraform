# Provider
provider "aws" {
  region = "us-east-2"
}

# Data Sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}



# Security group ec2 instances
resource "aws_security_group" "instance" {
  name = "web-instances"
  description = "Permite trafico HTTP al puerto del servidor"



 ingress { 
  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
 }



 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
}


# Launch template 
resource "aws_launch_template" "example" {
  name_prefix = "web-"
  image_id = "ami-0a695f0d95cefc163"
  instance_type = "t3.micro"



  vpc_security_group_ids = [aws_security_group.instance.id]


  # Script para un hola mundo
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Hello World" > index.html
    HOSTNAME=$(hostname)
    nohup busybox httpd -f -p ${var.server_port} &
  EOF
  )

  tag_specifications {
    resource_type = "instance"


    tags = {
      Name = "web"
    }
  }
}


# Load balancer security group
resource "aws_security_group" "alb" {
  name = "web-alb"
  description = "Permite trafico HTTP al ALB"

  ingress { 
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # ALB necesita salida libre
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}


# Aplication load balancer
resource "aws_lb" "example" {
  name = "web-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

# Target group
resource "aws_lb_target_group" "asg" {
  name = "web-target-group"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}


# Listener HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"


  # Respuesta por defecto, en caso de NO tener reglas
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code = 404
    }
  }
}


# Listener Rule > Envia al target group
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100


  condition {
    path_pattern {
      values = [ "*" ]
    }
  }


  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


# Auto scaling  
resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  health_check_type = "ELB"

  target_group_arns = [aws_lb_target_group.asg.arn]
  
  launch_template {
    id = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "web"
    propagate_at_launch = true
  }
}

