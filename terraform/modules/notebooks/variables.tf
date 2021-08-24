variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "region" {
  type        = string
  description = "The region that this terraform configuration will use."
}

variable "location" {
  type        = string
  description = "The zone that this terraform configuration will use."
}

variable "instance_type" {
  type        = string
  description = "The instance_type that this terraform configuration will use."
}

variable "gpu_type" {
  type        = string
  description = "The GPU type: https://cloud.google.com/gpu"
}

variable "gpu_count" {
  type        = number
  description = "The GPU number"
}

variable "label_value" {
  default = "enabled"
}