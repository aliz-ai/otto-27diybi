module "network" {
  source = "./modules/network"

  project_id = var.project_id
  region     = var.region
  ip_range   = var.vpc_ip_range
  env        = var.env
}

module "ai-notebooks" {
  source = "./modules/notebooks"

  project_id    = var.project_id
  region        = var.region
  location      = var.zone
  instance_type = var.instance_type
  gpu_type      = var.gpu_type
  gpu_count     = var.gpu_count
}

module "functions-start-stop" {
  source                    = "./modules/cloud-functions"
  project_id                = var.project_id
  pattern_stop              = var.pattern_stop
  pattern_start             = var.pattern_start
  label_key                 = var.label_key
  label_value               = var.label_value
  scheduler_function_bucket = var.scheduler_function_bucket
  timezone                  = var.timezone
}