resource "aws_ecr_repository" "webapp-laravel" {
  name = "neosperience-webapp-laravel-${var.env}"
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "webapp-nginx" { //this could also be shared between multiple php services if the design is similar
  name = "neosperience-webapp-nginx-${var.env}"
  image_scanning_configuration {
    scan_on_push = true
  }
}