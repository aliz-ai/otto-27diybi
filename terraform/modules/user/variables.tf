variable "project_id" {}
variable "region" {}
variable "team" {}
variable "featureid" {}
variable "environment" {}
variable "location" {}
variable "instance_type" {}
variable "commons_bucket" {}
variable "network" {}
variable "subnet" {}
variable "user_group_mappings" {
  type = map(object({
    group_email = string
    user_id     = string
  }))
}