resource "aws_route53_zone" "private" {
  count           = var.local_dns ? 1 : 0
  name            = var.main_dns

  vpc {
    vpc_id        = aws_vpc.generic.id
  }
}