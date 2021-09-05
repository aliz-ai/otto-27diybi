
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
  iam_rule_prefix = "gcp-brain-iam"
  groups = {
    "ml@aliz.ai" = {
      members = [
        "norbert.liki@aliz.ai"
      ],
      prefix   = "p"
      dataprep = true
    },
    "infra@aliz.ai" = {
      members = [
        "taufik.romdony@aliz.ai"
      ],
      prefix   = "h"
      dataprep = false
    }
  }

  dataprep_roles = "roles/CHANGE-TO-DATAPREP-CUSTOM-ROLE"

  group_emails = toset([
    for group_email, group_definition in local.groups :
    group_email
  ])

  dataprep = compact(flatten([
    for group_email, group_definition in local.groups : [
      group_definition.dataprep == true ? group_email : ""
    ]
  ]))

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

  user_group_mappings_by_id = {
    for entry in local.user_group_mappings :
    "${entry.group_email}#${entry.user_id}" => entry
  }
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