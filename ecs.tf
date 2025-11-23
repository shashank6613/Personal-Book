# --- ECR REPOSITORIES ---
resource "aws_ecr_repository" "frontend_repo" {
  name = "${var.project_name}-frontend"
  force_delete = true
}

resource "aws_ecr_repository" "backend_repo" {
  name = "${var.project_name}-backend"
  force_delete = true
}

# --- CLUSTER ---
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# --- CLOUDWATCH LOGS ---
resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.project_name}"
}

# --- BACKEND TASK DEFINITION ---
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn # Crucial for Lambda invoke

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-backend-container"
      image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      essential = true
      portMappings = [{ containerPort = 5000, hostPort = 5000 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
      # Environment Variables for the Backend
      environment = [
        { name = "PORT", value = "5000" },
        { name = "MONGO_URI", value = var.mongo_uri },
        { name = "JWT_SECRET", value = var.jwt_secret },
        { name = "AWS_REGION", value = var.aws_region },
        { name = "SENDER_EMAIL_ADDRESS", value: var.sender_email_address }
      ]
    }
  ])
}

# --- FRONTEND TASK DEFINITION ---
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-frontend-container"
      image     = "${aws_ecr_repository.frontend_repo.repository_url}:latest"
      essential = true
      portMappings = [{ containerPort = 80, hostPort = 80 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])
}

# --- BACKEND SERVICE ---
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "${var.project_name}-backend-container"
    container_port   = 5000
  }
}

# --- FRONTEND SERVICE ---
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "${var.project_name}-frontend-container"
    container_port   = 80
  }
}
