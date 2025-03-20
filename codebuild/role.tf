data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name = "${var.prefix}-codebuild-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "app_build_role" {
  name               = "${var.prefix}-app-build-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuilddeveloper_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
  role       = aws_iam_role.app_build_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.app_build_role.name
}

resource "aws_iam_role_policy_attachment" "codecommit_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  role       = aws_iam_role.app_build_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
  role       = aws_iam_role.app_build_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_autorization_policy_attachment" {
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
  role       = aws_iam_role.app_build_role.name
}

data "aws_iam_policy_document" "codebuild_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::skills-codepipeline-artifacts-bucket",
      "arn:aws:s3:::skills-codepipeline-artifacts-bucket/*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_s3_policy" {
  name   = "${var.prefix}-codebuild-s3-policy"
  role   = aws_iam_role.app_build_role.id
  policy = data.aws_iam_policy_document.codebuild_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role      = aws_iam_role.app_build_role.name
}
