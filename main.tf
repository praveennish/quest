provider "aws" {
  region = var.region
  profile = var.profile

}

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "quest-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.vpc_cidr_block1
  availability_zone       = var.zone1

  tags = {
    Name = "quest-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.vpc_cidr_block2
  availability_zone       = var.zone2

  tags = {
    Name = "quest-subnet-2"
  }
}

resource "aws_key_pair" "default" {
  key_name   = "quest-instance-key"
  public_key = var.ssh_pub_key

  tags = {
    Name  = "quest-instance-key"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "quest-igw"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.default.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "quest-rt"
  }
}


resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
vpc_id = aws_vpc.default.id

  ingress {
    from_port                 = 8080
    to_port                   = 8080
    protocol                  = "tcp"
    security_groups           = [aws_security_group.alb_sg.id]  # Allowing traffic from ALB only
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with more restrictive IP range for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }

}
resource "aws_lb" "web_lb" {
  name               = "quest-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
} 

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "web-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

/*

# Listener
  resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = "arn:aws:acm:us-west-1:941500193593:certificate/17a8cfc9-24a6-45b6-a279-bb959ba76a6e"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}*/

resource "aws_instance" "default" {
 # availability_zone = aws_subnet.default.availability_zone
  instance_type = var.instance_type
  ami = "ami-08d4f6bbae664bd41"
  key_name = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id = aws_subnet.subnet1.id
  associate_public_ip_address = true
  depends_on = [aws_internet_gateway.default]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum -y install docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo chmod 666 /var/run/docker.sock

    cat <<EOT > /home/ec2-user/Dockerfile
      FROM node:10
      WORKDIR /app
      RUN git clone https://github.com/rearc/quest.git /app/
      RUN cp /app/src/000.js /app/index.js
      RUN npm init -y && npm install express
      CMD ["node", "index.js"]
    EOT

    cd /home/ec2-user/
    docker build -t quest .
    docker run -d -p 8080:3000 --name quest quest

    sleep 100

    SECRET_WORD=$(curl -s localhost:8080)
    docker stop quest
    docker rm quest
    docker run -d -p 8080:3000 --name quest -e SECRET_WORD="$SECRET_WORD" quest

  EOF

  instance_initiated_shutdown_behavior = "terminate"
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.default.id
  port             = 8080
}