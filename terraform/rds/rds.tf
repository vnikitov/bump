module "db-bump" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "bump"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t3.medium"
  allocated_storage = 10

  name     = "bump"
  username = var.db_username
  password = var.db_password
  port     = "21321"

  multi_az                            = false
  iam_database_authentication_enabled = true

  create_db_subnet_group    = true
  create_db_parameter_group = true

  vpc_security_group_ids = [aws_security_group.allow_mysql.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  publicly_accessible = false
  storage_encrypted   = true

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "rds_monitoring_role"
  create_monitoring_role = true

  tags = merge(local.common_tags,
    {
      Name = "bump-db"
    },
  )

  # DB subnet group
  subnet_ids = data.terraform_remote_state.core.outputs.vpc_database_id

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}


resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

  ingress {
    description      = "Allow 21321"
    from_port        = 21321
    to_port          = 21321
    protocol         = "tcp"
    cidr_blocks      = data.terraform_remote_state.core.outputs.vpc_private_cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mysql"
  }
}
