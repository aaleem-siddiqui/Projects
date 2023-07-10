data "aws_region" "current" {}

locals {
  name = format("%s-%s-%s",
    var.stack,
    var.project,
    replace(data.aws_region.current.name, "-", "")
  )
  tags = merge(
    {
      ENVIRONMENT             = var.stack
      Terraform_managed       = "True"
      AWS_REGION              = data.aws_region.current.name
    },
    var.tags
  )
}