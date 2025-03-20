resource "aws_codecommit_repository" "application_repository" {
  repository_name = "${var.prefix}-application-repo"

  default_branch = "main"

  tags = {
    Name = "${var.prefix}-application-repo"
  }
}

resource "aws_codecommit_repository" "gitops_repository" {
  repository_name = "${var.prefix}-gitops-repo"

  default_branch = "main"

  tags = {
    Name = "${var.prefix}-gitops-repo"
  }
}