# ------------------------------------------------------------------------------
# Root Main.tf - ECS Infrastructure
# This file orchestrates the creation of ECR repositories, IAM roles, and ECS tasks
# ------------------------------------------------------------------------------

# Create ECR Repositories for each container
module "ecr_repositories" {
  source                       = "../hive-tf-iac-modules-aws/ecr"
  naming_convention_properties = var.naming_convention_properties
  for_each                     = var.ecr_repositories

  repository_name      = each.value.repository_name
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  encryption_configuration     = each.value.encryption_configuration
  image_scanning_configuration = each.value.image_scanning_configuration

  tags = merge(
    var.default_tags,
    { Name = each.value.repository_name }
  )
}

# Create IAM Roles (Task Role and Execution Role)
module "iam_roles" {
  source                       = "../hive-tf-iac-modules-aws/iam"
  naming_convention_properties = var.naming_convention_properties
  for_each                     = var.iam_roles

  role_name          = each.key
  description        = each.value.description
  assume_role_policy = each.value.assume_role_policy
  managed_policies   = each.value.managed_policies
  inline_policies    = each.value.inline_policies

  tags = merge(
    var.default_tags,
    { Name = each.key }
  )
}

# Create ECS Cluster (single cluster for all tasks)
module "ecs_cluster" {
  source                       = "../hive-tf-iac-modules-aws/ecs"
  naming_convention_properties = var.naming_convention_properties

  task_name              = "cluster-only" # Placeholder name
  container_name         = "placeholder"
  container_image        = "placeholder:latest"
  task_role_arn          = module.iam_roles.iam_roles["ecsTaskRole"].role_arn
  execution_role_arn     = module.iam_roles.iam_roles["ecsExecutionRole"].role_arn
  aws_region             = var.aws_region
  container_insights_enabled = var.container_insights_enabled

  tags = var.default_tags

  # We only want the cluster, not the task definition
  # This is a workaround - in production, consider splitting cluster and task definition modules
}

# Create ECS Task Definitions
module "ecs_task_definitions" {
  source                       = "../hive-tf-iac-modules-aws/ecs"
  naming_convention_properties = var.naming_convention_properties
  for_each                     = var.ecs_task_definitions

  task_name              = each.key
  container_name         = each.value.container_name
  container_image        = each.value.container_image != "" ? each.value.container_image : "${module.ecr_repositories[each.value.ecr_repository_key].repository_url}:${each.value.image_tag}"
  cpu                    = each.value.cpu
  memory                 = each.value.memory
  task_role_arn          = module.iam_roles.iam_roles["ecsTaskRole"].role_arn
  execution_role_arn     = module.iam_roles.iam_roles["ecsExecutionRole"].role_arn
  aws_region             = var.aws_region
  port_mappings          = each.value.port_mappings
  environment_variables  = each.value.environment_variables
  secrets                = each.value.secrets
  mount_points           = each.value.mount_points
  volumes_from           = each.value.volumes_from
  volumes                = each.value.volumes
  log_retention_days     = each.value.log_retention_days
  container_insights_enabled = var.container_insights_enabled

  tags = merge(
    var.default_tags,
    { Name = each.key }
  )

  depends_on = [
    module.ecr_repositories,
    module.iam_roles
  ]
}