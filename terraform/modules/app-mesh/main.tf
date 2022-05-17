resource "aws_appmesh_mesh" "main" {
    name = "privatier-local"
}

resource "aws_appmesh_virtual_gateway" "main" {
    name = "vg-main"
    mesh_name = aws_appmesh_mesh.main.name

    spec {
        listener {
          port_mapping {
            port = 80
            protocol = "http"
          }
        }
    }
}