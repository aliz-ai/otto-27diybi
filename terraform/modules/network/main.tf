resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.env}"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "subnet-${var.env}"
  ip_cidr_range            = var.ip_range
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "rtr-${var.env}"
  region  = var.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "nat_address" {
  name         = "nat-ip-${var.env}"
  address_type = "EXTERNAL"
}

resource "google_compute_router_nat" "nat" {
  name                                = "nat-gw-${var.env}"
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
  network = google_compute_network.vpc.self_link
}

# This enables private services access. This makes it possible for instances
# within the VPC and Google services to communicate exclusively using internal
# IP addresses. Details here:
#   https://cloud.google.com/sql/docs/postgres/configure-private-services-access

resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.vpc.self_link
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_block.name
  ]
}

# We'll need this to connect to the Cloud SQL Proxy.

resource "google_compute_firewall" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH traffic to any instance tagged with 'ssh-enabled'"
  network     = google_compute_network.vpc.name
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }

  target_tags = [
    "ssh-enabled"
  ]
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name        = "allow-iap-ssh"
  description = "Allow SSH ingress from iap"
  network     = google_compute_network.vpc.name
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

  target_tags = [
    "iap-ssh",
    "bastion"
  ]
}
