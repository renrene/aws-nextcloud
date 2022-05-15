resource "aws_service_discovery_service" "main" {
  name = local.service_name

  dns_config {
    namespace_id = var.service_registry_id

    dns_records {
      ttl  = 15
      type = "SRV"
    }

    routing_policy = "WEIGHTED"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
