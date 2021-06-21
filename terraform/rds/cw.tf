module "rds_cpu" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"

  alarm_name          = "cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Average database CPU utilization over last 10 minutes too high"

  #alarm_actions = [module.opsgenie-alerts.this_sns_topic_arn]
  #ok_actions    = [module.opsgenie-alerts.this_sns_topic_arn]

  dimensions = {
    "db-bump" = {
      DBInstanceIdentifier = module.db-bump.db_instance_id
    }
  }
}

module "rds_queue_depth" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"

  alarm_name          = "disk_queue_depth_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "2"
  datapoints_to_alarm = "1"
  alarm_description   = "Average database disk queue depth over last 10 minutes too high, performance may suffer"

  #alarm_actions = [module.opsgenie-alerts.this_sns_topic_arn]
  #ok_actions    = [module.opsgenie-alerts.this_sns_topic_arn]

  dimensions = {
    "db-bump" = {
      DBInstanceIdentifier = module.db-bump.db_instance_id
    }
  }
}

module "rds_freeable_memory_too_low" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"

  alarm_name          = "freeable_memory_too_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "1000000000"
  alarm_description   = "Average database freeable memory over last 10 minutes too low, performance may suffer"

  #alarm_actions = [module.opsgenie-alerts.this_sns_topic_arn]
  #ok_actions    = [module.opsgenie-alerts.this_sns_topic_arn]

  dimensions = {
    "db-bump" = {
      DBInstanceIdentifier = module.db-bump.db_instance_id
    }
  }
}

module "rds_free_storage_space_threshold" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"

  alarm_name          = "free_storage_space_threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "20000000000"
  alarm_description   = "Average database free storage space over last 10 minutes too low"

  #alarm_actions = [module.opsgenie-alerts.this_sns_topic_arn]
  #ok_actions    = [module.opsgenie-alerts.this_sns_topic_arn]

  dimensions = {
    "db-bump" = {
      DBInstanceIdentifier = module.db-bump.db_instance_id
    }
  }
}

module "rds_swap_usage_too_high" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"

  alarm_name          = "swap_usage_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "50000000"
  alarm_description   = "Average database swap usage over last 10 minutes too high, performance may suffer"

  #alarm_actions = [module.opsgenie-alerts.this_sns_topic_arn]
  #ok_actions    = [module.opsgenie-alerts.this_sns_topic_arn]

  dimensions = {
    "db-bump" = {
      DBInstanceIdentifier = module.db-bump.db_instance_id
    }
  }
}