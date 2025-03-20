

resource "tls_private_key" "bastin-key" {
    algorithm = "RSA"
    rsa_bits = 2048

}

resource "aws_key_pair" "bastion-key-pair" {
  key_name = "${var.prefix}-key"
  public_key = tls_private_key.bastin-key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  content = tls_private_key.bastin-key.private_key_pem
  filename = "${path.module}/bastion_key.pem"
}