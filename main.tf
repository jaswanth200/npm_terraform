terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"  # Ensure this version works with your modules
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

############################# V P C ####################################
#creating vpc
resource "aws_vpc" "provpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
     
    Name = "provpc"
  }
}

############################## I G ########################################

#creating internet_gateway
resource "aws_internet_gateway" "proig" {
  vpc_id = aws_vpc.provpc.id

  tags = {
    Name = "proig"
  }
}

############################## A V A L_Z O N E_1A ###################################

#creating subnet in avalibitlity zone us-east-1a
resource "aws_subnet" "aval_1a_subnet" {
  vpc_id     = aws_vpc.provpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "aval_1a_subnet"
  }
}

#creating route table for aval-1a
resource "aws_route_table" "aval_1a_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }

  tags = {
    Name = "aval_1a_rt"
  }
}

#attaching public route table to avalabitlity zone 1a subnet 
resource "aws_route_table_association" "public_attach_1a" {
  subnet_id      = aws_subnet.aval_1a_subnet.id
  route_table_id = aws_route_table.aval_1a_rt.id
}

############################ A V A L_Z O N E_1b #########################################

#creating subnet avalibitlity zone us-east-1b
resource "aws_subnet" "aval_1b_subnet" {
  vpc_id     = aws_vpc.provpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-1b"


  tags = {
    Name = "aval_1b_subnet"
  }  
}


#creating route table for aval-1b
resource "aws_route_table" "aval_1b_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }

  tags = {
    Name = "aval_1b_rt"
  }
}

#attaching public route table to avalabitlity zone 1b subnet 
resource "aws_route_table_association" "public_attach_1b" {
  subnet_id      = aws_subnet.aval_1b_subnet.id
  route_table_id = aws_route_table.aval_1b_rt.id
}

########################### A V A L_Z O N E_1c ############################################

#creating subnet avalibitlity zone us-east-1c
resource "aws_subnet" "aval_1c_subnet" {
  vpc_id     = aws_vpc.provpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "us-east-1c"


  tags = {
    Name = "aval_1c_subnet"
  }  
}


#creating route table for aval-1c
resource "aws_route_table" "aval_1c_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }

  tags = {
    Name = "aval_1c_rt"
  }
}

#attaching public route table to avalabitlity zone 1c subnet 
resource "aws_route_table_association" "public_attach_1c" {
  subnet_id      = aws_subnet.aval_1c_subnet.id
  route_table_id = aws_route_table.aval_1c_rt.id
}


########################## SECURITY GROUP ###################################

#creating security_group for instances
resource "aws_security_group" "prosg" {
  name   = "prosg"
  vpc_id = aws_vpc.provpc.id
  description = "security_group"

  ingress {
    description = "http from all internet"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "http to all internet"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"] 
  }
}

########################### SG_LOAD BALANCER ###################################


#creating security_group for load balancer
resource "aws_security_group" "lbsg" {
  name   = "lbsg"
  vpc_id = aws_vpc.provpc.id
  description = "load_balancer_security_group"

  ingress {
    description = "http from all internet"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "http to all internet"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"] 
  }
}

######################## LOAD BALANCER ################################


#creating load balancer
resource "aws_lb" "prolb" {
  name               = "prolb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lbsg.id]
  subnets            = [aws_subnet.aval_1a_subnet.id,aws_subnet.aval_1b_subnet.id,aws_subnet.aval_1c_subnet.id]

  tags = {
    Environment = "production"
  }
}


#creating load balancer listener
resource "aws_lb_listener" "prolb_listener" {
  load_balancer_arn = aws_lb.prolb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prolb-targetgroup.arn
  }
}


#creating lb_target group
resource "aws_lb_target_group" "prolb-targetgroup" {
  name     = "prolb-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.provpc.id
}



#################################### VARIABLES ############################################

#defing variables
variable "asgmin" {
  type = number
  default = 1
  
}

variable "asgmax" {
  type = number
  default = 5
  
}

variable "asgdesired" {
  type = number
  default = 1

}

##################################### AUTO SCALLING ################################################

#creating launch configuration for autoscalling
resource "aws_launch_configuration" "pro_aws_asg_config" {
  name = "pro_aws_asg_config"
  image_id = aws_ami_from_instance.first_instance_ami.id
  instance_type = "t2.micro"
  key_name = "terraformkey"
  associate_public_ip_address = true
  security_groups = [aws_security_group.prosg.id]

}

#creating autoscallind group
resource "aws_autoscaling_group" "prod_auto_scale_grp" {
  name                      = "prod_auto_scale_grp"
  max_size                  = "${var.asgmax}"
  min_size                  = "${var.asgmin}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.asgdesired}"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.pro_aws_asg_config.name
  vpc_zone_identifier       = [aws_subnet.aval_1a_subnet.id,aws_subnet.aval_1b_subnet.id,aws_subnet.aval_1c_subnet.id]

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

# Create a attachement for load balancer and auto scalling group
resource "aws_autoscaling_attachment" "asd_attachment" {
  autoscaling_group_name = aws_autoscaling_group.prod_auto_scale_grp.id
  lb_target_group_arn                    = aws_lb_target_group.prolb-targetgroup.id
}


############# FIRST INSTANCE #################################################


resource "aws_instance" "first_instance" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.aval_1a_subnet.id
  security_groups = [aws_security_group.prosg.id]
  tags = {
    Name = "FirstInstance"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-11-jdk
              EOF
    key_name = "terraformkey"
    associate_public_ip_address = true
}



resource "aws_ami_from_instance" "first_instance_ami" {
  name               = "first-instance-ami"
  source_instance_id = aws_instance.first_instance.id
  depends_on         = [aws_instance.first_instance]
  tags = {
    Name = "FirstInstanceAMI"
  }
}


output "first_instance_id" {
  value = aws_instance.first_instance.id
}

output "first_instance_ami_id" {
  value = aws_ami_from_instance.first_instance_ami.id
}








