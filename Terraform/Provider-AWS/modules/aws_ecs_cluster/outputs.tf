output "cluster_arn" {
  description = "ARN of ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "cluster_id" {
  description = "The ID of the created ECS cluster."
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "cluster_name" {
  description = "The name of the created ECS cluster."
  value       = aws_ecs_cluster.ecs_cluster.name
}

