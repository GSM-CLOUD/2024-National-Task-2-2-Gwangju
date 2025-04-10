resource "aws_ecr_repository" "ecr_app" {
    name = "${var.prefix}-ecr-app"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    
    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "${var.prefix}-ecr-app"
    }
}