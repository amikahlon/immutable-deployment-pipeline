module "network" {
  source = "./modules/network"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  az_1                  = var.az_1
  az_2                  = var.az_2
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

module "github_oidc" {
  source = "./modules/github-oidc"

  project_name         = var.project_name
  aws_region           = var.aws_region
  github_org           = var.github_org
  github_repo          = var.github_repo
  create_oidc_provider = var.create_oidc_provider
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  aws_region            = var.aws_region
  private_subnet_ids    = module.network.private_subnet_ids
  app_security_group_id = module.network.app_security_group_id
  client_repository_url = module.ecr.client_repository_url
  server_repository_url = module.ecr.server_repository_url
  image_tag             = var.image_tag
  instance_type         = var.instance_type
  min_size              = var.asg_min_size
  max_size              = var.asg_max_size
  desired_capacity      = var.asg_desired_capacity
  client_tg_arn = module.alb.client_tg_arn
  server_tg_arn = module.alb.server_tg_arn
}
