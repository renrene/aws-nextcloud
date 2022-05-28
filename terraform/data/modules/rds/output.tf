output "rds_instance" {
    value = { for k,v in aws_db_instance.main : k => v }
    description = "The RDS instance object"
}

output "db_security_group" {
    value = aws_security_group.main.id
    description = "db instance main security group id"
}