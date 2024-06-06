terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "networking" {
  backend = "local"
  config = {
    path = "../fold1/terraform.tfstate"  # Path to the first configuration's state file
  }
}

#################################### LOAD BALANCER SECURITY GROUP ############################################

# Creating security group for load balancer
resource "aws_security_group" "lbsg" {
  name        = "lbsg"
  vpc_id      = data.terraform_remote_state.networking.outputs.provpc
  description = "load_balancer_security_group"

  ingress {
    description = "http from all internet"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "http to all internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#################################### LOAD BALANCER ############################################

# Creating load balancer
resource "aws_lb" "prolb" {
  name               = "prolb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lbsg.id]
  subnets            = [
    data.terraform_remote_state.networking.outputs.aval_1a_subnet,
    data.terraform_remote_state.networking.outputs.aval_1b_subnet,
    data.terraform_remote_state.networking.outputs.aval_1c_subnet
  ]

  tags = {
    Environment = "production"
  }
}

# Creating load balancer listener
resource "aws_lb_listener" "prolb_listener" {
  load_balancer_arn = aws_lb.prolb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prolb_targetgroup.arn
  }
}

# Creating lb_target group
resource "aws_lb_target_group" "prolb_targetgroup" {
  name     = "prolb-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networking.outputs.provpc
}

#################################### VARIABLES ############################################

# Defining variables
variable "asgmin" {
  type    = number
  default = 1
}

variable "asgmax" {
  type    = number
  default = 5
}

variable "asgdesired" {
  type    = number
  default = 1
}

##################################### AUTO SCALING ################################################

# Creating launch configuration for autoscaling
resource "aws_launch_configuration" "pro_aws_asg_config" {
  name                      = "pro_aws_asg_config"
  image_id                  = data.terraform_remote_state.networking.outputs.first_instance_ami
  instance_type             = "t2.micro"
  key_name                  = "terraformkey"
  security_groups           = [data.terraform_remote_state.networking.outputs.prosg]
  associate_public_ip_address = true
}

# Creating autoscaling group
resource "aws_autoscaling_group" "prod_auto_scale_grp" {
  name                      = "prod_auto_scale_grp"
  max_size                  = var.asgmax
  min_size                  = var.asgmin
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.asgdesired
  force_delete              = true
  launch_configuration      = aws_launch_configuration.pro_aws_asg_config.name
  vpc_zone_identifier       = [
    data.terraform_remote_state.networking.outputs.aval_1a_subnet,
    data.terraform_remote_state.networking.outputs.aval_1b_subnet,
    data.terraform_remote_state.networking.outputs.aval_1c_subnet
  ]

  instance_maintenance_policy {
    min_healthy_percentage = 60
    max_healthy_percentage = 120
  }

  tag {
    key                 = "terraformkey"
    value               = "bar"
    propagate_at_launch = true
  }
}

# Create an attachment for load balancer and autoscaling group
resource "aws_autoscaling_attachment" "asd_attachment" {
  autoscaling_group_name = aws_autoscaling_group.prod_auto_scale_grp.id
  lb_target_group_arn    = aws_lb_target_group.prolb_targetgroup.arn
}
