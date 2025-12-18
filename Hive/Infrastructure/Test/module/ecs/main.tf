# ------------------------------------------------------------------------------
# ECS Cluster Module
# This module creates an AWS ECS cluster with task definitions
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "this" {
  name = "${var.naming_convention_properties.project}-ecs-cluster-${var.naming_convention_properties.environment}"

  setting {
    name  = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }

  tags = var.tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.naming_convention_properties.project}-task-${var.naming_convention_properties.environment}-${var.task_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = var.port_mappings

      environment = var.environment_variables

      secrets = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.naming_convention_properties.project}-${var.naming_convention_properties.environment}-${var.task_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      mountPoints = var.mount_points
      volumesFrom = var.volumes_from
    }
  ])

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port
          authorization_config {
            access_point_id = efs_volume_configuration.value.authorization_config.access_point_id
            iam             = efs_volume_configuration.value.authorization_config.iam
          }
        }
      }
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for ECS Task
resource "aws_cloudwatch_log_group" "ecs_task" {
  name              = "/ecs/${var.naming_convention_properties.project}-${var.naming_convention_properties.environment}-${var.task_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}