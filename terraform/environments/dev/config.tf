
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
  groups = {
    "ml@aliz.ai" = {
      members = [
        "norbert.liki@aliz.ai",
        "tamas.moricz@aliz.ai"
      ],
    },
    "infra@aliz.ai" = {
      members = [
        "taufik.romdony@aliz.ai",
      ],
    }
  }

  group_emails = toset([
    for group_email, group_definition in local.groups :
    group_email
  ])

  group_members = flatten([
    for group_email, group_definition in local.groups : [
      for member in group_definition.members :
      member
    ]
  ])

  user_group_mappings = flatten([
    for group_email, group_definition in local.groups : [
      for member in group_definition.members :
      {
        group_email = group_email
        user_id     = member
      }
    ]
  ])
}

# static team & infrastructure config
locals {
  team       = "diybi"
  featureid  = "003-112"
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
    team      = local.team
    featureid = local.featureid
  }
}