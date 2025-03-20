resource "aws_s3_bucket" "codepipeline_artifacts" {
  force_destroy = true
  bucket = "${var.prefix}-codepipeline-artifacts-bucket"
}