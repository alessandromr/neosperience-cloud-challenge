data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "neosperience-test-terraform-${var.env}"
    key    = "infra-${var.env}/network/terraform.tfstate"
    region = var.aws_region
  }
}
