####  Security Group for Application Load Balancer (ALB)  ####

resource "aws_security_group" "ALB_sg" {
  name        = "ALB_sg"
  description = "Security group for RabbitMQ ALB"
  vpc_id      = var.vpc_id

  # Inbound: HTTP (optional for management UI)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # you can restrict to admin IPs later
    description = "HTTP access to RabbitMQ management UI"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  # Inbound: AMQP (if clients connect directly to ALB)


  tags = {
    Name = "ALB_sg"
  }
}

####  Security Group for EC2 Instances (RabbitMQ Nodes)  ####

resource "aws_security_group" "EC2_sg" {
  name        = "EC2_sg_rabbit"
  description = "Security group for RabbitMQ EC2 instances"
  vpc_id      = var.vpc_id

  # Allow AMQP traffic from ALB

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "AMQP traffic from VPC"
  }

  # Allow management UI traffic from ALB
  ingress {
    from_port       = 15672
    to_port         = 15672
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_sg.id]
    description     = "Management UI from ALB"
  }

  # Allow management UI traffic from NLB
  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow NLB health checks to management UI"
  }

  # Outbound: allow everything (required for metadata, DNS, docker pulls)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound connections"
  }

  tags = {
    Name = "EC2_sg_rabbit"
  }
}

######  Additional Security Groups rules ######

# Erlang node discovery (EPMD)
resource "aws_security_group_rule" "rabbit_epmd" {
  type                     = "ingress"
  from_port                = 4369
  to_port                  = 4369
  protocol                 = "tcp"
  security_group_id        = aws_security_group.EC2_sg.id
  source_security_group_id = aws_security_group.EC2_sg.id
  description              = "Erlang node discovery (EPMD)"
}

# RabbitMQ inter-node communication
resource "aws_security_group_rule" "rabbit_cluster" {
  type                     = "ingress"
  from_port                = 25672
  to_port                  = 25672
  protocol                 = "tcp"
  security_group_id        = aws_security_group.EC2_sg.id
  source_security_group_id = aws_security_group.EC2_sg.id
  description              = "RabbitMQ inter-node communication"
}
