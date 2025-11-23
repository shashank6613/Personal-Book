# --- ECS EXECUTION ROLE (Runs the task/pulls images) ---
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- ECS TASK ROLE (Permissions for your specific App code) ---
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Allow ECS Task (Backend) to send emails via SES
resource "aws_iam_role_policy" "ecs_ses_policy" {
  name = "${var.project_name}-ses-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Mongoose and MongoDB related permissions (optional but good practice for full access control)
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters", # If you were to use SSM for secrets
        ],
        Resource = "*"
      },
      # NEW: Required SES permissions to send emails
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
        ],
        Resource = "*", # Allows sending from any verified identity
      }
    ]
  })
}
