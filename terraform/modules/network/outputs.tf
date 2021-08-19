output "link" {
  description = "A link to the VPC resource, useful for creating resources inside the VPC"
  value       = google_compute_network.vpc.self_link
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "subnetwork_name" {
  description = "The name of the Subnetwork"
  value       = google_compute_subnetwork.subnetwork.name
}

output "private_vpc_connection" {
  description = "The private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection
}
