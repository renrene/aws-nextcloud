module "ecs-ngnix" {
    source = "./modules/ecs-ngnix"
    vpc_id = module.vpc.attributes.vpc_id

    depends_on = [
      module.vpc
    ]
  
}