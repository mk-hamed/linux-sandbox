resource "aws_ecr_repository" "landing" {
  name                 = "linux-sandbox-landing"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_repository" "sandbox" {
  name                 = "linux-sandbox"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

output "landing_ecr_uri" {
  value = aws_ecr_repository.landing.repository_url
}

output "sandbox_ecr_uri" {
  value = aws_ecr_repository.sandbox.repository_url
}