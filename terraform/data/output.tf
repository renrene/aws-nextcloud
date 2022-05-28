output "vpc" {
    value = { for k,v in module.vpc : k => v }
    description = "The Data VPC object"
    sensitive = true
}

output "nextcloud_rds_instance" {
    value = { for k,v in module.db-nextcloud.rds_instance : k => v }
    description = "Nextcloud RDS instance object"
    sensitive = true
}

output "nextcloud_db_security_group" {
    value = module.db-nextcloud.db_security_group
    description = "db instance main security group id"
}
