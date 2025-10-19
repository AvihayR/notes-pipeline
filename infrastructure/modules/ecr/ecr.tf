resource "aws_ecr_repository" "notes_repo" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.repo_name
  }

}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.notes_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v"]
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

output "url" {
  value = aws_ecr_repository.notes_repo.repository_url
}
