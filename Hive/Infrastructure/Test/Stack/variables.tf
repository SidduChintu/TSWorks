# ------------------------------------------------------------------------------
# Root Variables
# ------------------------------------------------------------------------------

variable "naming_convention_properties" {
  description = "Naming convention properties for AWS resources"
  type = object({
    project     = string
    environment = string
    purpose     = optional(string)
    index       = optional(string)
  })
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "container_insights_enabled" {
  description = "Enable container insights for ECS cluster"
  type        = bool
  default     = true
}

variable "ecr_repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    repository_name      = string
    image_tag_mutability = string
    force_delete         = bool
    encryption_configuration = optional(object({
      encryption_type = optional(string, "AES256")
      kms_key         = optional(string, null)
    }))
    image_scanning_configuration = optional(object({
      scan_on_push = optional(bool, false)
    }))
  }))
  default = {}
}

variable "iam_roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    description        = string
    assume_role_policy = string
    managed_policies   = list(string)
    inline_policies = map(object({
      policy = string
    }))
  }))
  default = {}
}

variable "ecs_task_definitions" {
  description = "Map of ECS task definitions to create"
  type = map(object({
    container_name       = string
    container_image      = optional(string, "")
    ecr_repository_key   = optional(string, "")
    image_tag            = optional(string, "latest")
    cpu                  = string
    memory               = string
    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
    })), [])
    environment_variables = optional(list(object({
      name  = string
      value = string
    })), [])
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
    mount_points = optional(list(object({
      sourceVolume  = string
      containerPath = string
      readOnly      = bool
    })), [])
    volumes_from = optional(list(any), [])
    volumes = optional(list(object({
      name = string
      efs_volume_configuration = optional(object({
        file_system_id          = string
        root_directory          = optional(string)
        transit_encryption      = optional(string)
        transit_encryption_port = optional(number)
        authorization_config = optional(object({
          access_point_id = optional(string)
          iam             = optional(string)
        }))
      }))
    })), [])
    log_retention_days = optional(number, 7)
  }))
  default = {}
}