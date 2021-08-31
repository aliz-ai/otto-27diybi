resource "google_storage_bucket" "commons" {
  name          = "${var.project_id}-commons"
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

resource "google_storage_bucket_object" "startup-files" {
  for_each   = toset(var.gcs_files)
  bucket     = google_storage_bucket.commons.name
  name       = each.value
  content    = file("${path.root}/../../../startup/${each.value}")
  depends_on = [google_storage_bucket.commons]
}
resource "google_storage_bucket" "cf-bucket" {
  name = "${var.project_id}-cf-bucket"
}

data "archive_file" "notebook_backup" {
  type        = "zip"
  source_dir  = "${path.root}/../../../notebook_backup" # Directory where your Python source code is
  output_path = "${path.root}/../../../generated/notebook_backup.zip"
}

resource "google_storage_bucket_object" "archive" {
  name       = "${data.archive_file.notebook_backup.output_md5}.zip"
  bucket     = google_storage_bucket.cf-bucket.name
  source     = "${path.root}/../../../generated/notebook_backup.zip"
  depends_on = [google_storage_bucket.cf-bucket]
}

resource "google_storage_bucket_object" "archive-commons" {
  name       = "${data.archive_file.notebook_backup.output_md5}.zip"
  bucket     = google_storage_bucket.commons.name
  source     = "${path.root}/../../../generated/notebook_backup.zip"
  depends_on = [google_storage_bucket.commons]
}

resource "google_service_account" "cf-notebook-backup-sa" {
  project      = var.project_id
  account_id   = "cf-notebook-backup-sa"
  display_name = "Terraform-managed service account for Cloud Function Notebooks Backup"
}

resource "google_project_iam_member" "cf_sa_invokers" {
  project = var.project_id
  member  = "serviceAccount:${google_service_account.cf-notebook-backup-sa.email}"
  role    = "roles/cloudfunctions.invoker"
}

resource "google_cloudfunctions_function" "backup-function" {
  name        = "notebook-backup-service"
  description = "Function for AI Notebook Backup"
  runtime     = "python37"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cf-bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "backup_project_notebooks"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.backup-function.project
  region         = google_cloudfunctions_function.backup-function.region
  cloud_function = google_cloudfunctions_function.backup-function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.cf-notebook-backup-sa.email}"
}

resource "google_cloud_scheduler_job" "job" {
  name             = "notebook-backup-trigger"
  description      = "Backup Notebook"
  schedule         = var.cron_pattern_backup
  time_zone        = var.timezone
  attempt_deadline = "320s"
  region           = "europe-west1"

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.backup-function.https_trigger_url

    oidc_token {
      service_account_email = google_service_account.cf-notebook-backup-sa.email
      audience              = google_cloudfunctions_function.backup-function.https_trigger_url
    }
  }
  depends_on = [google_cloudfunctions_function.backup-function]
}

resource "google_bigquery_dataset" "bq-dataset" {
  dataset_id                  = "billing_export_dataset"
  friendly_name               = "billing_export"
  description                 = "Billing Export"
  location                    = "EU"
  default_table_expiration_ms = 3600000
}
