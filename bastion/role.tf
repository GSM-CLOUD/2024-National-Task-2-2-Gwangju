resource "aws_iam_role" "bastion_role" {
    name = "${var.prefix}-bastion-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.prefix}-bastion-instance-profile-role"
  role = aws_iam_role.bastion_role.name
}

resource "aws_eks_access_entry" "bastion_eks_access" {
  cluster_name = var.cluster_name
  principal_arn = aws_iam_role.bastion_role.arn
}

resource "aws_eks_access_policy_association" "bastion_eks_access_policy" {
  cluster_name = var.cluster_name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.bastion_role.arn
  
  access_scope {
    type = "cluster"
  }
}