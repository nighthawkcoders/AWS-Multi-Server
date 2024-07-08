provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "webapp1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "webapp2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "db" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "agent" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
}

resource "aws_subnet" "cpx" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
}

resource "aws_subnet" "windows" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
}

resource "aws_security_group" "webapp_sg" {
  vpc_id = aws_vpc.main.id

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
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "agent_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
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

resource "aws_security_group" "cpx_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3389
    to_port     = 3389
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


resource "aws_instance" "webapp1" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with a valid Ubuntu AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.webapp1.id
  security_groups = [aws_security_group.webapp_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "NCS WebApp 1"
  }
}

resource "aws_instance" "webapp2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.webapp2.id
  security_groups = [aws_security_group.webapp_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "NCS WebApp 2"
  }
}

resource "aws_instance" "db" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.db.id
  security_groups = [aws_security_group.db_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "NCS DB"
  }
}

resource "aws_instance" "agent" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.agent.id
  security_groups = [aws_security_group.agent_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "NCS Kasm Agent"
  }
}

resource "aws_instance" "cpx" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.cpx.id
  security_groups = [aws_security_group.cpx_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "NCS CPX"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.webapp1.id
}

resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_webapp1" {
  subnet_id      = aws_subnet.webapp1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_webapp2" {
  subnet_id      = aws_subnet.webapp2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_lb" "public" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp_sg.id]
  subnets            = [aws_subnet.webapp1.id, aws_subnet.webapp2.id]
}

resource "aws_lb_listener" "webapp" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp.arn
  }
}

resource "aws_lb_target_group" "webapp" {
  name     = "webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group_attachment" "webapp1" {
  target_group_arn = aws_lb_target_group.webapp.arn
  target_id        = aws_instance.webapp1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webapp2" {
  target_group_arn = aws_lb_target_group.webapp.arn
  target_id        = aws_instance.webapp2.id
  port             = 80
}
