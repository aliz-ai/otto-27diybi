variable "name" {
  description = "The service account name (e.g. cloud-sql-proxy)"
  type        = string
}

variable "roles" {
  description = "The roles assigned to the service account (e.g. roles/cloudsql.editor)"
  type        = list(string)
}

variable "display_name" {
  description = "Display name for service account"
  type        = string
}
