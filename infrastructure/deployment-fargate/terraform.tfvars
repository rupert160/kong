name_preffix="kong"
profile="capgemini"
region="ap-southeast-2"
availability_zones= [ "ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c" ]
vpc_cidr_block="172.35.0.0/16"
public_subnets_cidrs_per_availability_zone= [ "172.35.0.0/19", "172.35.32.0/19", "172.35.64.0/19", "172.35.96.0/19" ]
private_subnets_cidrs_per_availability_zone= [ "172.35.128.0/19", "172.35.160.0/19", "172.35.192.0/19", "172.35.224.0/19" ]
container_image="735655096069.dkr.ecr.ap-southeast-2.amazonaws.com/kong:1.3.0"
container_name="kong"
container_port=8001
ecs_cluster_name="kong"
#ecs_cluster_arn=
#private_subnets_ids
#public_subnets_ids
#subnets
#task_definition_arn
#vpc_id
enable_ecs_managed_tags = true
propagate_tags = "SERVICE"

