output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "app_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet_app : subnet.id]
}


output "private_db_subnets"{
   value = [for subnet in aws_subnet.private_subnet_database : subnet.id]

}

output "private_db_subnet_cidr" {
  value = [for subnet in aws_subnet.private_subnet_app : subnet.cidr_block]
}

output "rds_sg" {
  value = aws_security_group.rds_sg.id
}

output "availability_zones"{
      value = [for availability_zone in aws_subnet.private_subnet_app : availability_zone.id]

}

output "environment" {
  value = var.environment
}
