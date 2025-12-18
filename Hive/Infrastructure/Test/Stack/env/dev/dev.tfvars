# ------------------------------------------------------------------------------
# Terraform Variables Configuration
# ------------------------------------------------------------------------------

naming_convention_properties = {
  project     = "hive"
  environment = "dev"
}

aws_region = "us-east-1"

default_tags = {
  "project"     = "hive"
  "environment" = "dev"
  "deployed_by"  = "Terraform"
  "ops_team"    = "devops"
}

container_insights_enabled = true

# ------------------------------------------------------------------------------
# ECR Repositories - One for each container
# ------------------------------------------------------------------------------
ecr_repositories = {
  "demographics-repo" = {
    repository_name      = "demographics"
    image_tag_mutability = "MUTABLE"
    force_delete         = true

    encryption_configuration = {
      encryption_type = "AES256"
    }

    image_scanning_configuration = {
      scan_on_push = true
    }
  }

  "framework-repo" = {
    repository_name      = "framework"
    image_tag_mutability = "MUTABLE"
    force_delete         = true

    encryption_configuration = {
      encryption_type = "AES256"
    }

    image_scanning_configuration = {
      scan_on_push = true
    }
  }

  "surface-repo" = {
    repository_name      = "surface"
    image_tag_mutability = "MUTABLE"
    force_delete         = true

    encryption_configuration = {
      encryption_type = "AES256"
    }

    image_scanning_configuration = {
      scan_on_push = true
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Roles - Task Role and Execution Role (same permissions as per requirement)
# ------------------------------------------------------------------------------
iam_roles = {
  ecsTaskRole = {
    description        = "ECS Task IAM role with full access to S3, RDS, Secrets Manager, and network interfaces"
    assume_role_policy = "policies/ecs-role-policies/ecs-task-assume-role.json.tmpl"
    managed_policies = [
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
      "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]

    inline_policies = {
      NetworkInterfacePolicy = {
        policy = "policies/ecs-role-policies/ecs-network-interface-policy.json.tmpl"
      }
      KMSPolicy = {
        policy = "policies/ecs-role-policies/ecs-kms-policy.json.tmpl"
      }
      S3CustomPolicy = {
        policy = "policies/ecs-role-policies/ecs-s3-custom-policy.json.tmpl"
      }
    }
  }

  ecsExecutionRole = {
    description        = "ECS Execution IAM role with full access to S3, RDS, Secrets Manager, and network interfaces"
    assume_role_policy = "policies/ecs-role-policies/ecs-task-assume-role.json.tmpl"
    managed_policies = [
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
      "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]

    inline_policies = {
      NetworkInterfacePolicy = {
        policy = "policies/ecs-role-policies/ecs-network-interface-policy.json.tmpl"
      }
      KMSPolicy = {
        policy = "policies/ecs-role-policies/ecs-kms-policy.json.tmpl"
      }
      S3CustomPolicy = {
        policy = "policies/ecs-role-policies/ecs-s3-custom-policy.json.tmpl"
      }
    }
  }
}

# ------------------------------------------------------------------------------
# ECS Task Definitions - Three task definitions with different containers
# ------------------------------------------------------------------------------
ecs_task_definitions = {
  "demographics" = {
    container_name     = "demographics"
    ecr_repository_key = "demographics-repo"
    image_tag          = "latest"
    cpu                = "512"
    memory             = "1024"

    port_mappings = [
      {
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }
    ]

    environment_variables = [
      {
        name  = "APP_ENV"
        value = "dev"
      },
      {
        name  = "secrets_postgres"
        value = "rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad"
      }
      {
        name  = "secret_name"
        value = "hive-secret-dev"
      }
    
    ]

    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad-C6wBtL:password::"
      }
      {
        name     = "DB_USER"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad-C6wBtL:username::"
      }
      {
        name     = "ANOTHER_SECRET"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:hive-secret-dev-MMncTL:db_url::"
      }
    ]

    log_retention_days = 7
  }

  "framework" = {
    container_name     = "framework"
    ecr_repository_key = "framework-repo"
    image_tag          = "latest"
    cpu                = "512"
    memory             = "1024"

    port_mappings = [
      {
        containerPort = 8081
        hostPort      = 8081
        protocol      = "tcp"
      }
    ]

    environment_variables = [
      {
        name  = "APP_ENV"
        value = "dev"
      },
      {
        name  = "secrets_postgres"
        value = "rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad"
      }
      {
        name  = "secret_name"
        value = "hive-secret-dev"
      }
    
    ]

    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad-C6wBtL:password::"
      }
      {
        name     = "DB_USER"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad-C6wBtL:username::"
      }
      {
        name     = "ANOTHER_SECRET"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:hive-secret-dev-MMncTL:db_url::"
      }
    ]

    log_retention_days = 7
  }

  "surface" = {
    container_name     = "surface"
    ecr_repository_key = "surface-repo"
    image_tag          = "latest"
    cpu                = "256"
    memory             = "512"

    port_mappings = [
      {
        containerPort = 8082
        hostPort      = 8082
        protocol      = "tcp"
      }
    ]

    environment_variables = [
      {
        name  = "APP_ENV"
        value = "dev"
      },
      {
        name  = "secrets_postgres"
        value = "rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad"
      }
      {
        name  = "secret_name"
        value = "hive-secret-dev"
      }
    
    ]

    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad-C6wBtL:password::"
      }
      {
        name     = "DB_USER"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:rds!cluster-4ca6389a-15da-49ee-b31d-03de79159bad-C6wBtL:username::"
      }
      {
        name     = "ANOTHER_SECRET"
        valueFrom = "arn:aws:secretsmanager:us-east-1:093427367861:secret:hive-secret-dev-MMncTL:db_url::"
      }
    ]

    log_retention_days = 7
  }
}