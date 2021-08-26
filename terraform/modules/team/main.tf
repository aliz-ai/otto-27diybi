resource "google_storage_bucket" "team-collaboration" {
  name          = "${var.team}-collaboration"
  location      = "EU"
  force_destroy = true
  labels        = var.label
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_bigquery_dataset" "team-dataset" {
  dataset_id                  = "team_${var.team}"
  friendly_name               = "team-${var.team}"
  description                 = "Team ${var.team} Dataset"
  location                    = "EU"
  default_table_expiration_ms = 2419200000 #(28days)
  labels                      = var.label
}

resource "google_service_account" "team_sa" {
  account_id   = var.sa_name
  display_name = var.display_name
}

resource "google_service_account_iam_member" "team-account-iam" {
  service_account_id = google_service_account.team_sa.name
  role               = "roles/iam.serviceAccountUser"
  #member   = "user:taufik.romdony@aliz.ai"
  for_each = toset(var.members)
  member     = each.key
}

resource "google_project_iam_member" "team_sa_role" {
  for_each = toset(var.roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.team_sa.email}"
}