resource "random_string" "service_account_suffix" {
  upper   = false
  lower   = true
  special = false
  length  = 4
}

resource "google_service_account" "serviceaccount" {
  account_id   = "${substr(var.name, 0, min(15, length(var.name)))}-${random_string.service_account_suffix.result}"
  display_name = var.display_name
}

resource "google_project_iam_member" "serviceaccount_role" {
  for_each = toset(var.roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.serviceaccount.email}"
}
