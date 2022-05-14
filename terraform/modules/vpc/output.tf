output "attributes" {
    value = { for key, value in module.vpc : key => value}
    description = "All internal VPC module outputs"
}