provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}
provider "google-beta" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}