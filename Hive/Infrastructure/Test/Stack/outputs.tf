# ------------------------------------------------------------------------------
# Root Outputs
# ------------------------------------------------------------------------------

# ECR Repository Outputs
output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value = {
    for k, v in module.ecr_repositories : k => v.repository_url
  }
}

output "ecr_repository_arns" {
  description = "ARNs of the ECR repositories"
  value = {
    for k, v in module.ecr_repositories : k => v.repository_arn
  }
}

# IAM Role Outputs
output "iam_role_arns" {
  description = "ARNs of the IAM roles"
  value = {
    for k, v in module.iam_roles : k => v.role_arn
  }
}

output "task_role_arn" {
  description = "ARN of the ECS Task Role"
  value       = module.iam_roles["ecsTaskRole"].role_arn
}

output "execution_role_arn" {
  description = "ARN of the ECS Execution Role"
  value       = module.iam_roles["ecsExecutionRole"].role_arn
}

# ECS Cluster Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

# ECS Task Definition Outputs
output "task_definition_arns" {
  description = "ARNs of the ECS task definitions"
  value = {
    for k, v in module.ecs_task_definitions : k => v.task_definition_arn
  }
}

output "task_definition_families" {
  description = "Families of the ECS task definitions"
  value = {
    for k, v in module.ecs_task_definitions : k => v.task_definition_family
  }
}

output "log_group_names" {
  description = "Names of the CloudWatch Log Groups"
  value = {
    for k, v in module.ecs_task_definitions : k => v.log_group_name
  }
}