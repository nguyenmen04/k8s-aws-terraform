terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Data Sources ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "k8s-alb-sg"
  description = "Allow inbound HTTP traffic to ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "k8s-ec2-sg"
  description = "Allow traffic from ALB to NodePort and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Allow NodePort 30000 from ALB"
    from_port       = 30000
    to_port         = 30000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow SSH for debugging"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Application Load Balancer ---
resource "aws_lb" "app_alb" {
  name               = "k8s-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app_tg" {
  name     = "k8s-app-tg"
  port     = 30000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = "30000"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# --- EC2 Instance ---
resource "aws_instance" "k8s_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Pass base64-encoded strings to avoid template substitution/escaping hell
  user_data = templatefile("${path.module}/user_data.tpl.sh", {
    index_html = file("${path.module}/app/index.html")
    styles_css = file("${path.module}/app/styles.css")
    app_js     = file("${path.module}/app/app.js")
    data_json  = file("${path.module}/app/data.json")
    dockerfile = file("${path.module}/app/Dockerfile")
  })

  tags = {
    Name = "K8s-Kind-Node"
  }
}

resource "aws_lb_target_group_attachment" "k8s_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.k8s_node.id
  port             = 30000
}

# --- Multi-Provider Requirement (Null Provider) ---
# Simulate a wait time for user_data to finish setting up Docker and Kind.
resource "null_resource" "wait_for_k8s" {
  depends_on = [aws_instance.k8s_node]

  provisioner "local-exec" {
    command = "echo 'Terraform created EC2. User data is running in the background. K8s will be up in a few minutes.'"
  }
}
