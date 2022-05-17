terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.14"
        }
    }
}

module "apigw" {
    source = "./modules/apigw"
    vpc_link_security_groups = [ module.ecs-ngnix.ecs_security_group_id ]
    vpc_link_subnets = module.vpc.attributes.public_subnets
    public_hosted_zone = "net.rhizomatic.biz"
    service_arn = module.ecs-ngnix.discovery_service_arn
}
