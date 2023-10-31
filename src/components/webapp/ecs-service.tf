
module "webapp_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = "neosperience-webapp-${var.env}"
  cluster_arn = data.terraform_remote_state.shared.outputs.ecs_cluster_arn

  cpu    = 1024
  memory = 2048

  # Container definition(s)
  container_definitions = {

    php = {
      cpu       = 960
      memory    = 1920
      essential = true
      image     = aws_ecr_repository.webapp-laravel.repository_url
      readonly_root_filesystem = false
    }

    nginx = {
      cpu       = 64
      memory    = 128
      essential = true
      image     = aws_ecr_repository.webapp-nginx.repository_url
      readonly_root_filesystem = false

      port_mappings = [
        {
          name          = "nginx"
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  }

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture = "ARM64"
  }

  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.webapp_tg.arn
      container_name   = "nginx"
      container_port   = 80
    }
  }

  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = data.terraform_remote_state.shared.outputs.alb_sg_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name     = "neosperience-test-webapp-tg-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener_rule" "webapp_listener_rule_http" {
  listener_arn = data.terraform_remote_state.shared.outputs.alb_http_listener_arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }

  condition {
    http_header {
      http_header_name = "x-cf-token"
      values = [random_string.alb_token.result]
    }
  }
}


