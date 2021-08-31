
# dynamic service config
locals {
  environment         = "dev"
  project             = local.project_id
  cron_pattern_backup = "0 0 22 * *"
  timezone            = "Europe/Berlin"
  instance_type       = "n1-standard-2"
  commons_bucket      = "${local.project_id}-commons"

  gcs_config_files = [
    "00startup.py",
    "shutdown_script.sh",
  ]

  sa_name      = "team-${local.team}-sa"
  display_name = "Terraform-managed service account for ${local.team}"
  roles = [
    "roles/notebooks.admin",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataOwner",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/monitoring.viewer"
  ]

  team_members = [
    "user:taufik.romdony@aliz.ai",
    "group:ml@aliz.ai"
  ]
}

# static team & infrastructure config
locals {
  team       = "etwas"
  module     = "003-113"
  user       = "taufik"
  project_id = "aliz-diybi-ia"
  region     = "europe-west1"
  zone       = "${local.region}-b"
  #host_project     = "brain-central-prd"
  network_name      = "default"
  network_id        = "projects/${local.project_id}/global/networks/${local.network_name}"
  network_self_link = "https://www.googleapis.com/compute/v1/${local.network_id}"
  subnet_name       = "default"
  subnet_id         = "projects/${local.project_id}/regions/${local.region}/subnetworks/${local.subnet_name}"
  subnet_self_link  = "https://www.googleapis.com/compute/v1/${local.subnet_id}"
  labels = {
    team   = local.team
    module = local.module
  }
}