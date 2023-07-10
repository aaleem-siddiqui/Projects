/* ---------- Create private S3 bucket ---------- */
resource "aws_s3_bucket" "generic_bucket" {
  count           = length(var.s3_bucket_name) > 0 ? length(var.s3_bucket_name) : 0
  bucket          = element(var.s3_bucket_name, count.index)
  tags            = local.tags
}