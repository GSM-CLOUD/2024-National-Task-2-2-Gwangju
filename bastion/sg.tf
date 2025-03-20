resource "aws_security_group" "bastion-sg" {
  vpc_id = var.vpc_id
  description = "bastion-sg"
  ingress = [{
    description = "bastion-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress = [{
    description = "bastion-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]
}

resource "aws_security_group_rule" "eks_primary_sg_ingress" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = var.primary_cluster_sg_id
  source_security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group_rule" "eks_sg_ingress" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = var.cluster_sg_id
  source_security_group_id = aws_security_group.bastion-sg.id
}