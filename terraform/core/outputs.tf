output "vpc_database_id" {
  value = module.vpc.database_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_id" {
  value = module.vpc.public_subnets
}

output "vpc_private_id" {
  value = module.vpc.private_subnets
}

output "vpc_private_cidrs" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "lb_arn" {
  value = aws_lb.lb-bump.arn
}

output "lb_id" {
  value = aws_lb.lb-bump.id
}

output "lb_dns" {
  value = aws_lb.lb-bump.dns_name
}

output "aws_alb_target_group_arn" {
  value = aws_alb_target_group.tg-bump.arn
}