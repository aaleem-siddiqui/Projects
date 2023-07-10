resource "aws_ecs_cluster" "ecs_cluster" {
  name  = local.prefix
  tags = merge(
      {
          TERRAFORM_MANAGED = "TRUE"
      },
      var.tags
  )
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}
