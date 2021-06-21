resource "aws_iam_role" "worker_ecs_task_execution_role" {
  name = "worker-${var.name}-ecsTaskExecutionRole"

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

resource "aws_iam_role" "worker_ecs_task_role" {
  name = "worker-${var.name}-ecsTaskRole"

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


resource "aws_iam_role_policy_attachment" "worker-ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.worker_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-secrets" {
#  role       = aws_iam_role.worker_ecs_task_execution_role.name
#  policy_arn = aws_iam_policy.secrets.arn
#}

resource "aws_cloudwatch_log_group" "worker" {
  name = "/ecs/worker-${var.name}-task-${var.env}"

  tags = merge(local.common_tags,
    {
      Name = "worker-${var.name}-task-${var.env}"
    },
  )
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "worker-${var.name}-task-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.worker_container_cpu
  memory                   = var.worker_container_memory
  execution_role_arn       = aws_iam_role.worker_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.worker_ecs_task_role.arn

  container_definitions = jsonencode([{
    name        = "worker-${var.name}-container-${var.env}"
    image       = "${var.worker_container_image}:latest"
    essential   = true
    #environment = var.container_environment
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.worker_container_port
      hostPort      = var.worker_container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.worker.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
    #secrets = var.container_secrets
  }])

  tags = merge(local.common_tags,
    {
      Name = "worker-${var.name}-task-${var.env}"
    },
  )
}

resource "aws_ecs_cluster" "worker" {
  name = "worker-${var.name}-cluster-${var.env}"
  tags = merge(local.common_tags,
    {
      Name = "worker-${var.name}-task-${var.env}"
    },
  )
}

resource "aws_ecs_service" "worker" {
  name                               = "worker-${var.name}-service-${var.env}"
  cluster                            = aws_ecs_cluster.worker.id
  task_definition                    = aws_ecs_task_definition.worker.arn
  desired_count                      = var.service_desired_count

  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.allow_http.id]
    subnets          = data.terraform_remote_state.core.outputs.vpc_private_id
    assign_public_ip = false
  }
}

resource "aws_appautoscaling_target" "worker_ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.worker.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "worker_ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.worker_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "worker_ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.worker_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_security_group" "worker_allow_http" {
  name        = "worker_allow_http"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

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

  tags = merge(local.common_tags,
    {
      Name = "worker-${var.name}-sg-${var.env}"
    },
  )
}