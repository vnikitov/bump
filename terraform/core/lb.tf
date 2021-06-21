# Define application Loadbalancer
resource "aws_lb" "lb-bump" {
  name               = "bump-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_https.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = local.common_tags
}


# Security group for the Loadbalancer
resource "aws_security_group" "allow_http_https" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_https"
  }
}

# Define the target groups
resource "aws_alb_target_group" "tg-bump" {
  name        = "${var.name}-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = merge(local.common_tags,
    {
      Name = var.name
    },
  )
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.lb-bump.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg-bump.id
    type             = "forward"
  }
}
