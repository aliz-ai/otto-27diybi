variable "project_id" {}
variable "region" {}
variable "team" {}
variable "user" {}
variable "username" {}
variable "location" {}
variable "instance_type" {}
variable "label" {}
variable "commons_bucket" {}
variable "network" {}
variable "subnet" {}
variable "group_members" {
  type = set(string)
}