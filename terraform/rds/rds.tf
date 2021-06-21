module "db-bump" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "bump"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.large"
  allocated_storage = 10

  name     = "bump"
  username = "admins"
  password = "strojg&dsgh342"
  port     = "3306"

  iam_database_authentication_enabled = true

  #vpc_security_group_ids = [module.postgres_security_group.this_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  publicly_accessible = false
  storage_encrypted   = true

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
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
