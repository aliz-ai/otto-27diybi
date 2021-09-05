variable "project_id" {}
variable "team" {}
variable "featureid" {}
variable "environment" {}
variable "dataprep_role" {}
variable "group_emails" {
  type = set(string)
}
variable "dataprep_enable" {
  type = set(string)
}

variable "user_group_mappings" {
  type = map(object({
    group_email = string
    user_id     = string
  }))
}