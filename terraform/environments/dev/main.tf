module "project-level" {
  source = "../../modules/project"

  project_id          = local.project
  gcs_files           = local.gcs_config_files
  cron_pattern_backup = local.cron_pattern_backup
  timezone            = local.timezone
  label               = local.labels
}

module "team-level" {
  source = "../../modules/team"

  project_id   = local.project
  team         = local.team
  label        = local.labels
  sa_name      = local.sa_name
  display_name = local.display_name
  roles        = local.roles

}

module "user-level" {
  source = "../../modules/user"

  project_id     = local.project
  team           = local.team
  label          = local.labels
  location       = local.zone
  instance_type  = local.instance_type
  gpu_type       = local.gpu_type
  gpu_count      = local.gpu_count
  commons_bucket = "${local.project_id}-commons"
  network        = local.network_id
  subnet         = local.subnet_id

}