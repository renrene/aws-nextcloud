data "aws_route53_zone" "public" {
    name = var.public_hosted_zone
    private_zone = false
}

data "aws_acm_certificate" "public" {
    domain = local.acm_domain
    types = ["AMAZON_ISSUED"]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}