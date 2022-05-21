resource "aws_service_discovery_service" "main" {
  name = var.ecs_service_name

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

resource "aws_appmesh_virtual_node" "main" {
  name = "vn-${var.ecs_service_name}"
  mesh_name = var.app_mesh_name

  spec {
    listener {
      port_mapping {
        port = 80
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name = aws_service_discovery_service.main.name
        namespace_name = var.namespace_name
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "main" {
  name = "${var.ecs_service_name}.${var.namespace_name}"
  mesh_name = var.app_mesh_name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.main.name
      }
    }
  }
}
