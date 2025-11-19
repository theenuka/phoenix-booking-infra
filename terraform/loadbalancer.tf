# --- 1. Security Group (Same as before) ---
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
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
  tags = { Name = "${var.project_name}-alb-sg" }
}

# --- 2. The Load Balancer (Same as before) ---
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]
  tags = { Name = "${var.project_name}-alb" }
}

# --- 3. Target Group A: FRONTEND (Port 30001) ---
resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-frontend-tg"
  port     = 30001
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = 30001
  }
}

# --- 4. Target Group B: API GATEWAY (Port 30000) ---
resource "aws_lb_target_group" "api" {
  name     = "${var.project_name}-api-tg"
  port     = 30000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health" # Checks if API is alive
    port = 30000
  }
}

# --- 5. Listener (The Router) ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # DEFAULT ACTION: Send to Frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# --- 6. Listener Rule: If path is /api/* -> Send to API Gateway ---
resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# --- 7. Attach Workers to Frontend Group ---
resource "aws_lb_target_group_attachment" "frontend_workers" {
  count            = 2
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.k8s_worker[count.index].id
  port             = 30001
}

# --- 8. Attach Workers to API Group ---
resource "aws_lb_target_group_attachment" "api_workers" {
  count            = 2
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.k8s_worker[count.index].id
  port             = 30000
}