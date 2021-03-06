resource "aws_iam_role" "web_ecs_task_execution_role" {
  name = "web-${var.name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "web_cs_task_role" {
  name = "web-${var.name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#resource "aws_iam_policy" "secrets" {
#  name        = "${var.name}-task-policy-secrets"
#  description = "Policy that allows access to the secrets we created"
#
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "AccessSecrets",
#            "Effect": "Allow",
#            "Action": [
#              "secretsmanager:GetSecretValue"
#            ],
#            "Resource": ${jsonencode(var.container_secrets_arns)}
#        }
#    ]
#}
#EOF
#}


resource "aws_iam_role_policy_attachment" "web-ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.web_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-secrets" {
#  role       = aws_iam_role.ecs_task_execution_role.name
#  policy_arn = aws_iam_policy.secrets.arn
#}

resource "aws_cloudwatch_log_group" "web" {
  name = "/ecs/web-${var.name}-task-${var.env}"

  tags = merge(local.common_tags,
    {
      Name = "web-${var.name}-task-${var.env}"
    },
  )
}

resource "aws_ecs_task_definition" "web" {
  family                   = "web-${var.name}-task-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.web_container_cpu
  memory                   = var.web_container_memory
  execution_role_arn       = aws_iam_role.web_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.web_ecs_task_role.arn

  container_definitions = jsonencode([{
    name        = "web-${var.name}-container-${var.env}"
    image       = "${var.container_image}:latest"
    essential   = true
    #environment = var.container_environment
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.web_container_port
      hostPort      = var.web_container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.web.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
    #secrets = var.container_secrets
  }])

  tags = merge(local.common_tags,
    {
      Name = "web-${var.name}-task-${var.env}"
    },
  )
}

resource "aws_ecs_cluster" "web" {
  name = "web-${var.name}-cluster-${var.env}"
  tags = merge(local.common_tags,
    {
      Name = "web-${var.name}-task-${var.env}"
    },
  )
}

resource "aws_ecs_service" "main" {
  name                               = "${var.name}-service-${var.env}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.web_service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.allow_http.id]
    subnets          = data.terraform_remote_state.core.outputs.vpc_private_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.core.outputs.aws_alb_target_group_arn
    container_name   = "${var.name}-container-${var.env}"
    container_port   = var.container_port
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

  ingress {
    description      = "Allow 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = data.terraform_remote_state.core.outputs.vpc_private_cidrs
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
    Name = "allow_http"
  }
}