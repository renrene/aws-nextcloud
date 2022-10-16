data "aws_region" "current" {}

data "terraform_remote_state" "shared" {
    backend = "s3"
    config = {
        bucket = "nextcloud-tf-state-backend"
        key = "shared"
        profile = "privatier"
        region = "eu-west-1"
     }
}
