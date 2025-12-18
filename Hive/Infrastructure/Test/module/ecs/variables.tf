# ------------------------------------------------------------------------------
# ECS Module Variables
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

variable "tags" {
  description = "Tags to assign to the ECS resources"
  type        = map(string)
  default     = {}
}

variable "task_name" {
  description = "Name identifier for the task definition"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image to use for the container"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task (1024 = 1 vCPU)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = string
  default     = "512"
}

variable "task_role_arn" {
  description = "ARN of the IAM role for the task"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for task execution"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "port_mappings" {
  description = "Port mappings for the container"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "Secrets from Secrets Manager or Parameter Store"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "mount_points" {
  description = "Mount points for the container"
  type = list(object({
    sourceVolume  = string
    containerPath = string
    readOnly      = bool
  }))
  default = []
}

variable "volumes_from" {
  description = "Volumes from other containers"
  type        = list(any)
  default     = []
}

variable "volumes" {
  description = "Volumes for the task definition"
  type = list(object({
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
  }))
  default = []
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}

variable "container_insights_enabled" {
  description = "Enable container insights for the ECS cluster"
  type        = bool
  default     = true
}