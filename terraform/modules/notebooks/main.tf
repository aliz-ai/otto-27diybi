resource "google_storage_bucket" "notebooks-bucket" {
  name          = "${var.project_id}-notebooks-bucket"
  location      = "EU"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_notebooks_instance" "instance" {
  provider           = google-beta
  name               = "nb-${random_id.instance_id.hex}"
  location           = var.location
  machine_type       = var.instance_type
  install_gpu_driver = true

  accelerator_config {
    type       = var.gpu_type
    core_count = var.gpu_count
  }

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-gpu"
  }

  boot_disk_type      = "PD_SSD"
  boot_disk_size_gb   = 110
  labels              = { "instance-scheduler" = var.label_value }
  post_startup_script = "gs://${google_storage_bucket.notebooks-bucket.name}"

  no_public_ip    = true
  no_proxy_access = true

  network = data.google_compute_network.vpc.id
  subnet  = data.google_compute_subnetwork.subnetwork.id

  service_account = module.serviceaccount.email
}

module "serviceaccount" {
  source = "../serviceaccount"

  name         = "ai-notebooks"
  display_name = "Terraform-managed service account for AI Notebooks"
  roles = [
    "roles/notebooks.admin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/monitoring.viewer"
  ]
}

data "google_compute_network" "vpc" {
  name = "vpc-dev"
}

data "google_compute_subnetwork" "subnetwork" {
  name   = "subnet-dev"
  region = var.region
}