output "caller_id" {
    value = data.aws_caller_identity.current.user_id
}

output "aws_region" {
    value = data.aws_region.current.id
  
}