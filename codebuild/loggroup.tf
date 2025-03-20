resource "aws_cloudwatch_log_group" "codebuild_logs" {
  name = "/aws/codebuild/${var.prefix}-app-build"
  retention_in_days = 7
}