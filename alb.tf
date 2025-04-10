# resource "aws_alb_target_group" "target-group-a" {
  
#   name     = "target-group-a"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id

# }


# resource "aws_alb_target_group" "target-group-b" {
  
#   name     = "target-group-b"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id

# }

# resource "aws_alb_target_group" "target-group-c" {
  
#   name     = "target-group-c"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id

# }

# resource "aws_lb_target_group_attachment" "tg-attachment-a" {
#  target_group_arn = aws_alb_target_group.target-group-a.arn
#  target_id        = aws_instance.example.id
#  port             = 80
# }

# resource "aws_lb_target_group_attachment" "tg-attachment-b" {
#  target_group_arn = aws_alb_target_group.target-group-b.arn
#  target_id        = aws_instance.example.id
#  port             = 80
# }

# resource "aws_lb_target_group_attachment" "tg-attachment-c" {
#  target_group_arn = aws_alb_target_group.target-group-c.arn
#  target_id        = aws_instance.example.id
#  port             = 80
# }


# resource "aws_alb" "lb-listener" {

#   name = "lb-listener"
#   internal = false
#   load_balancer_type = "application"
#   subnets = [aws_subnet.main.id, aws_subnet.backend.id, aws_subnet.data.id]

#     tags = {
#         Environment = "staff"
#     }

# }

# resource "aws_lb_listener" "app_listener" {
#   load_balancer_arn = aws_alb.lb-listener.arn
#   port   = 80
#   protocol = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_alb_target_group.target-group-a.arn
#   }
# }

# resource "aws_lb_listener_rule" "rule" {
#   listener_arn = aws_lb_listener.app_listener.arn
#   priority     = 60
#     action {
#         type = "forward"
#         target_group_arn = aws_alb_target_group.target-group-b.arn
#     }
#     condition {
#         path_pattern {
#             values = ["/images*"]
          
#         }
#     }
# }

# resource "aws_lb_listener_rule" "rule2" {
#   listener_arn = aws_lb_listener.app_listener.arn
#   priority     = 40
#     action {
#         type = "forward"
#         target_group_arn = aws_alb_target_group.target-group-c.arn
#     }
#     condition {
#         path_pattern {
#             values = ["/register*"]
          
#         }
#     }
# }