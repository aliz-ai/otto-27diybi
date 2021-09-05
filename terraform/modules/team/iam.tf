resource "google_service_account" "group_service_account" {
  for_each     = var.group_emails
  project      = var.project_id
  account_id   = replace(replace(each.key, "/@.*/", "-team-sa"), "/[\\._\\+~]/", "-")
  display_name = "Service Account for group ${each.key} to manage AI Notebooks."
}

resource "google_project_iam_member" "notebook_sa_custom_user_role" {
  for_each = var.group_emails
  project  = var.project_id
  role     = google_project_iam_custom_role.diy_bi_notebook_user_role.id
  member   = "serviceAccount:${google_service_account.group_service_account[each.key].email}"
  depends_on = [
    google_project_iam_custom_role.diy_bi_notebook_user_role,
  ]
}

resource "google_project_iam_custom_role" "diy_bi_notebook_sa_custom_role" {
  role_id     = "diyBiNotebookSA"
  title       = "diy:BI AI Notebooks SA"
  description = "Contains the minimal required permissions necessary for AI Notebooks service accounts with fine-grained security enabled."
  permissions = [
    "iam.serviceAccounts.actAs"
  ]
}

resource "google_project_iam_member" "notebook_sa_custom_sa_role" {
  for_each = var.group_emails
  project  = var.project_id
  role     = google_project_iam_custom_role.diy_bi_notebook_sa_custom_role.id
  member   = "serviceAccount:${google_service_account.group_service_account[each.key].email}"
}

resource "google_project_iam_member" "role_storage_bucket_get_sa" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "dataprep_integrate_sa_custom_sa_role" {
  for_each = var.dataprep_enable
  project  = var.project_id
  role     = var.dataprep_role
  member   = "serviceAccount:${google_service_account.group_service_account[each.key].email}"
}

resource "google_project_iam_custom_role" "diy_bi_notebook_user_role" {
  role_id     = "diyBiNotebookUser"
  title       = "diy:BI AI Notebooks user"
  description = "Contains the minimal required permissions necessary for AI Notebooks with fine-grained security enabled."
  permissions = [
    "storage.buckets.list",
    "storage.buckets.get",
    "bigquery.jobs.create",
    "bigquery.datasets.get",
    "bigquery.datasets.create",
    "bigquery.datasets.update",
    "bigquery.tables.create",
    "bigquery.tables.get",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "compute.machineTypes.get",
    "compute.networks.use",
    "compute.networks.access",
    "compute.networks.list",
    "compute.networks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.list",
    "compute.subnetworks.get",
    "compute.instances.get",
    "compute.instances.list",
    "compute.machineImages.get",
    "compute.addresses.get",
    "resourcemanager.projects.get",
    "serviceusage.quotas.get",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "notebooks.environments.get",
    "notebooks.environments.getIamPolicy",
    "notebooks.environments.list",
    "notebooks.executions.get",
    "notebooks.executions.getIamPolicy",
    "notebooks.executions.list",
    "notebooks.instances.checkUpgradability",
    "notebooks.instances.get",
    "notebooks.instances.getHealth",
    "notebooks.instances.getIamPolicy",
    "notebooks.instances.list",
    "notebooks.operations.get",
    "notebooks.operations.list",
    "notebooks.runtimes.get",
    "notebooks.runtimes.getIamPolicy",
    "notebooks.runtimes.list",
    "notebooks.schedules.get",
    "notebooks.schedules.getIamPolicy",
    "notebooks.schedules.list"
  ]
}