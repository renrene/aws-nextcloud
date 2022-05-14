module "ecs-ngnix" {
    source = "./modules/ecs-ngnix"
    vpc_id = module.vpc.attributes.vpc_id
    service_registry_arn = module.cloud-map.namespace_arn
    service_registry_id = module.cloud-map.namespace_id

    depends_on = [
      module.vpc,
      module.cloud-map
    ]
  
}

module "cloud-map" {
  source = "./modules/cloud-map"
  vpc_id = module.vpc.attributes.vpc_id

    depends_on = [
      module.vpc
    ]
  
}