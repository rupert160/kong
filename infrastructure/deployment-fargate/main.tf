# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  profile = var.profile
  region  = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
module "networking" {
   source          = "cn-terraform/networking/aws"
   version         = "2.0.4"
   name_preffix    = var.name_preffix
   profile         = var.profile
   region          = var.region
   vpc_cidr_block  = var.vpc_cidr_block
   availability_zones = var.availability_zones 
   public_subnets_cidrs_per_availability_zone  = var.public_subnets_cidrs_per_availability_zone
   private_subnets_cidrs_per_availability_zone = var.private_subnets_cidrs_per_availability_zone
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS Cluster
# ---------------------------------------------------------------------------------------------------------------------
module "ecs-cluster" {
  source  = "cn-terraform/ecs-cluster/aws"
  version = "1.0.2"
  name    = var.name_preffix
  profile = var.profile
  region  = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS Task Definition
# ---------------------------------------------------------------------------------------------------------------------
module "ecs-fargate-task-definition" {
  source       = "cn-terraform/ecs-fargate-task-definition/aws"
  version      = "1.0.3"
  name_preffix = var.name_preffix
  profile      = var.profile
  region       = var.region
  command = var.command
  container_name               = var.container_name
  container_image              = var.container_image
  container_port               = var.container_port
  container_cpu                = var.container_cpu
  container_depends_on         = var.container_depends_on
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  dns_servers                  = var.dns_servers
  entrypoint                   = var.entrypoint
  environment                  = var.environment
  essential                    = var.essential
  healthcheck                  = var.healthcheck
  links                        = var.links
  mount_points                 = var.mount_points
  readonly_root_filesystem     = var.readonly_root_filesystem
  repository_credentials       = var.repository_credentials
  secrets                      = var.secrets
  stop_timeout                 = var.stop_timeout
  ulimits                      = var.ulimits
  user                         = var.user
  volumes_from                 = var.volumes_from
  working_directory            = var.working_directory
  placement_constraints        = var.placement_constraints_task_definition
  proxy_configuration          = var.proxy_configuration
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS Service
# ---------------------------------------------------------------------------------------------------------------------
module "ecs-fargate-service" { 
  source              = "cn-terraform/ecs-fargate-service/aws"
  version             = "1.0.3"
  name_preffix        = var.name_preffix
  profile             = var.profile
  region              = var.region
	#vpc_id              = var.vpc_id
	#subnets             = var.private_subnets_ids
  ecs_cluster_name    = module.ecs-cluster.aws_ecs_cluster_cluster_name
  ecs_cluster_arn     = module.ecs-cluster.aws_ecs_cluster_cluster_arn
  task_definition_arn                = module.ecs-fargate-task-definition.aws_ecs_task_definition_td_arn
	container_name                     = var.container_name
  container_port                     = module.ecs-fargate-task-definition.container_port
  desired_count                      = var.desired_count
  platform_version                   = var.platform_version
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  propagate_tags                     = var.propagate_tags
  ordered_placement_strategy         = var.ordered_placement_strategy
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  placement_constraints              = var.placement_constraints_ecs_service
  service_registries                 = var.service_registries
  security_groups                    = var.security_groups
  assign_public_ip                   = var.assign_public_ip
	#availability_zones  = module.networking.availability_zones
	#public_subnets_ids  = module.networking.public_subnets_ids
	#private_subnets_ids = module.networking.private_subnets_ids
	subnets             = module.networking.private_subnets_ids
	vpc_id              = module.networking.vpc_id
}
