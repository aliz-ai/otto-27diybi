module "network" {
  source = "./modules/network"

  project_id = var.project_id
  region     = var.region
  ip_range   = var.vpc_ip_range
  env        = var.env
}
