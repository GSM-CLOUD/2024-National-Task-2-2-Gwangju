resource "aws_iam_user" "arocd_user" {
  name = "${var.prefix}-argocd-user"
}

resource "aws_iam_user_policy_attachment" "codecommit_full_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  user = aws_iam_user.arocd_user.name
}