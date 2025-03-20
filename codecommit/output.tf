output "app_repo_name" {
  value = aws_codecommit_repository.application_repository.repository_name
}

output "gitops_repo_name" {
  value = aws_codecommit_repository.gitops_repository.repository_name
}

output "app_repo_clone_url_http" {
  value = aws_codecommit_repository.application_repository.clone_url_http
}