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

resource "google_compute_router" "router" {
  name    = "rtr-${var.team}"
  region  = var.region
  network = var.network

  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "nat_address" {
  name         = "nat-ip-${var.team}"
  address_type = "EXTERNAL"
}

resource "google_compute_router_nat" "nat" {
  name                                = "nat-gw-${var.team}"
  router                              = google_compute_router.router.name
  region                              = google_compute_router.router.region
  enable_endpoint_independent_mapping = false
  min_ports_per_vm                    = 4096
  nat_ip_allocate_option              = "MANUAL_ONLY"
  nat_ips = [
    google_compute_address.nat_address.self_link
  ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_notebooks_instance" "instance" {
  provider     = google-beta
  name         = "${var.team}-${var.username}-notebook"
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
    gcs-data-bucket         = "${var.user}-backup"
    enable-guest-attributes = "true"
    framework               = "NumPy/SciPy/scikit-learn"
    installed-extensions    = "jupyterlab_bigquery-latest.tar.gz,jupyterlab_gcsfilebrowser-latest.tar.gz"
    shutdown-script         = "/opt/deeplearning/bin/shutdown_script.sh"
    notebooks-api           = "PROD"
    report-system-health    = "true"
  }
}

resource "google_storage_bucket" "user-backup" {
  name          = "${var.user}-backup"
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
