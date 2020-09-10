module "configuration" {
  source = "./modules/configuration"

  CIDR_BLOCK_16        = var.CIDR_BLOCK_16
  CIDR_BLOCK_0         = var.CIDR_BLOCK_0
  AWS_REGION           = var.AWS_REGION

}


module "application" {
  source = "./modules/application"
  AWS_REGION           = var.AWS_REGION
  AMIS                 = var.AMIS
  INSTANCE_TYPE        = var.INSTANCE_TYPE
  ENVIRONMENT          = var.ENVIRONMENT
  PATH_TO_PUBLICKEY    = var.PATH_TO_PUBLICKEY
  PATH_TO_PRIVATE_KEY  = var.PATH_TO_PRIVATE_KEY
  RDS_PASSWORD         = var.RDS_PASSWORD
  INSTANCE_DEVICE_NAME = var.INSTANCE_DEVICE_NAME
  CIDR_BLOCK_16        = var.CIDR_BLOCK_16
  CIDR_BLOCK_0         = var.CIDR_BLOCK_0
  INSTANCE_CLASS       = var.INSTANCE_CLASS
  VPC_ID               = module.configuration.main_vpc
  SUBNET_PUBLIC_1      = module.configuration.subnet_public1
  SUBNET_PUBLIC_2      = module.configuration.subnet_public2
  SUBNET_PUBLIC_3      = module.configuration.subnet_public3

}

module "policy_monitoring"{
  source = "./modules/policy_monitoring"
  AUTOSCALE_GRP = module.application.auto_scale_grp

}
