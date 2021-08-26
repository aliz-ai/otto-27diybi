# We need to allocate an IP block for private IPs. We want everything in the VPC
# to have a private IP. This improves security and latency, since requests to
# private IPs are routed through Google's network, not the Internet.

resource "google_compute_global_address" "private_ip_block" {
  name         = "private-ip-block"
  description  = "A block of private IP addresses that are accessible only from within the VPC."
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  # We don't specify a address range because Google will automatically assign one for us.
  prefix_length = 20
  # ~4k IPs
  network = var.network
}

# This enables private services access. This makes it possible for instances
# within the VPC and Google services to communicate exclusively using internal
# IP addresses. Details here:
#   https://cloud.google.com/sql/docs/postgres/configure-private-services-access

resource "google_service_networking_connection" "private_vpc_connection" {
  network = var.network
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_block.name
  ]
}

# We'll need this to connect to the AI Notebook Proxy.

resource "google_compute_firewall" "allow_iap_ssh" {
  name        = "allow-iap-ssh"
  description = "Allow SSH ingress from iap"
  network     = var.network
  direction   = "INGRESS"
  source_ranges = [
    "35.235.240.0/20"
  ]

  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }
}


resource "google_notebooks_instance" "instance" {
  provider     = google-beta
  name         = "${var.team}-notebook"
  location     = var.location
  machine_type = var.instance_type

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  boot_disk_type      = "PD_SSD"
  boot_disk_size_gb   = 100
  labels              = var.label
  post_startup_script = "gs://${var.commons_bucket}/shutdown_script.sh"

  no_public_ip    = true
  no_proxy_access = true

  network = var.network
  subnet  = var.subnet

  service_account = "team-${var.team}-sa@${var.project_id}.iam.gserviceaccount.com"

  metadata = {
    proxy-mode              = "service_account"
    gcs-data-bucket         = "${var.team}-backup"
    enable-guest-attributes = "true"
    framework               = "NumPy/SciPy/scikit-learn"
    installed-extensions    = "jupyterlab_bigquery-latest.tar.gz,jupyterlab_gcsfilebrowser-latest.tar.gz"
    shutdown-script         = "/opt/deeplearning/bin/shutdown_script.sh"
    notebooks-api           = "PROD"
    report-system-health    = "true"
    title                   = "Base.CPU"
    version                 = "78"
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_storage_bucket" "team-backup" {
  name          = "${var.team}-backup"
  location      = "EU"
  force_destroy = true
  labels        = var.label
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      age                = 28
      num_newer_versions = 100
    }
    action {
      type = "Delete"
    }
  }
}
