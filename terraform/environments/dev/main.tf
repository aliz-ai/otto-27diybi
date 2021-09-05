module "project-level" {
  source = "../../modules/project"

  project_id          = local.project
  region              = local.region
  gcs_files           = local.gcs_config_files
  cron_pattern_backup = local.cron_pattern_backup
  timezone            = local.timezone
  label               = local.labels
}

module "team-level" {
  source = "../../modules/team"

  project_id          = local.project
  team                = local.team
  environment         = local.environment
  featureid           = local.featureid
  group_emails        = local.group_emails
  dataprep_enable     = local.dataprep
  dataprep_role       = local.dataprep_roles
  user_group_mappings = local.user_group_mappings_by_id
}

module "user-level" {
  source = "../../modules/user"

  project_id          = local.project
  region              = local.region
  team                = local.team
  environment         = local.environment
  featureid           = local.featureid
  user_group_mappings = local.user_group_mappings_by_id
  location            = local.zone
  instance_type       = local.instance_type
  commons_bucket      = "${local.project_id}-commons"
  network             = local.network_id
  subnet              = local.subnet_id

}