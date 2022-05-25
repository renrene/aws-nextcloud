output "apigw_domain" {
    value = aws_route53_record.api.fqdn
}