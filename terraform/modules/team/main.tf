resource "google_storage_hmac_key" "hmac_key" {
  for_each              = var.group_emails
  service_account_email = google_service_account.group_service_account[each.key].email
  depends_on = [
    google_service_account.group_service_account,
  ]
}

output "hmac_secret" {
  value = tomap({
    for group_id, secret in google_storage_hmac_key.hmac_key : group_id => secret.secret
  })
}

output "hmac_access_id" {
  value = tomap({
    for group_id, secret in google_storage_hmac_key.hmac_key : group_id => secret.access_id
  })
}
resource "google_storage_bucket" "team_collaboration" {
  for_each      = var.group_emails
  name          = "${var.team}-${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")}-collaboration"
  location      = "EU"
  force_destroy = true
  labels = {
    featureid = var.featureid
    env       = var.environment
    team      = var.team
    group     = replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")
  }
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
resource "google_storage_bucket" "exasol_staging_bucket" {
  for_each      = var.group_emails
  name          = "${var.team}-${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")}-staging-exasol"
  location      = "EU"
  force_destroy = true
  labels = {
    featureid = var.featureid
    env       = var.environment
    team      = var.team
    group     = replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")
  }
  lifecycle_rule {
    condition {
      age = 28
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_bigquery_dataset" "team_dataset" {
  for_each                    = var.group_emails
  dataset_id                  = "${var.team}_${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")}"
  friendly_name               = "${var.team}-${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")}"
  description                 = "Team ${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")} Dataset"
  location                    = "EU"
  default_table_expiration_ms = 2419200000 #(28days)
  labels = {
    featureid = var.featureid
    env       = var.environment
    team      = var.team
    group     = replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")
  }
}

resource "google_bigquery_dataset_access" "access" {
  //restricted access to the dataset for the group only
  for_each       = var.group_emails
  dataset_id     = google_bigquery_dataset.team_dataset[each.key].dataset_id
  role           = "roles/bigquery.dataEditor"
  group_by_email = each.key
}

resource "google_bigquery_dataset_access" "service_account_access" {
  //restricted access to the dataset for the service account only
  for_each   = var.group_emails
  dataset_id = google_bigquery_dataset.team_dataset[each.key].dataset_id
  role       = "roles/bigquery.dataEditor"
  iam_member = "serviceAccount:${google_service_account.group_service_account[each.key].email}"
}

# # Team service accounts (read) diy-bi-commons bucket
resource "google_storage_bucket_iam_binding" "commons" {
  for_each = var.user_group_mappings
  bucket   = "${var.project_id}-commons"
  role     = "roles/storage.objectViewer"
  members  = ["serviceAccount:${google_service_account.group_service_account[each.value.group_email].email}"]
}

# Team service accounts (read) team-collaboration bucket
resource "google_storage_bucket_iam_binding" "team_collaboration" {
  for_each = var.group_emails
  bucket   = "${var.team}-${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")}-collaboration"
  role     = "roles/storage.objectViewer"
  members  = ["serviceAccount:${google_service_account.group_service_account[each.key].email}"]
}

# Team service accounts (read) team-staging exasol bucket
resource "google_storage_bucket_iam_binding" "team_staging_exasol" {
  for_each = var.group_emails
  bucket   = "${var.team}-${replace(replace(each.key, "/@.*/", ""), "/[\\._]/", "-")}-staging-exasol"
  role     = "roles/storage.objectViewer"
  members  = ["serviceAccount:${google_service_account.group_service_account[each.key].email}"]
}

# Team service accounts (read) user-backup bucket
resource "google_storage_bucket_iam_binding" "user_backup" {
  for_each = var.user_group_mappings
  bucket   = "${var.team}-${replace(replace(each.value.user_id, "/@.*/", ""), "/[\\._]/", "-")}-backup"
  role     = "roles/storage.objectAdmin"
  members  = ["serviceAccount:${google_service_account.group_service_account[each.value.group_email].email}"]
}