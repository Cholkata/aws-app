resource "aws_lb" "alb" {
  name               = "project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main-securityGroup.id]
  subnets            = [aws_subnet.main.id, aws_subnet.main2.id]

  enable_deletion_protection = false


  tags = {
    Name = "project-alb"
  }
}

resource "aws_lb_target_group" "alb-target-group" {
  name     = "project-target-group"
  port     = 80
  protocol = "HTTP" 
  target_type = "ip"
  vpc_id   = aws_vpc.main.id


  tags = {
    Name = "project-target-group"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "tcp"

  default_action {
    type = "redirect"
  
  redirect {
    port = "443"
    protocol = "HTTPS"
    status_code = "HTTP_301"

  }
}
  tags = {
    Name = "project-listener"
  }
}