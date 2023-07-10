/* ---------- Generate SSH key pair ---------- */
resource "tls_private_key" "generic_sshkey" {
  algorithm               = "RSA"
  rsa_bits                = 2048
}
/* ---------- Upload SSH public key to AWS ---------- */
resource "aws_key_pair" "generic" {
  key_name                = local.name
  public_key              = tls_private_key.generic_sshkey.public_key_openssh
  tags                    = merge(
    {
      "Name"              = local.name
    },
    local.tags
  )
}
/* ---------- Save SSH private key localy ---------- */
/* ---------- Key will be saved to current dir ---------- */
resource "null_resource" "ssh-private-key" {
  provisioner "local-exec" {
    command               = "echo \"${tls_private_key.generic_sshkey.private_key_pem}\" > ./\"${local.name}\".pem;"
  }
}
/* ---------- Create KMS key for ebs encryption ---------- */
resource "aws_kms_key" "custom_ebs_key" {
  description             = "custom_ebs_key"
  deletion_window_in_days = 30
  tags                    = merge(
    {
      "Name"              = local.name
    },
    local.tags
  )
}