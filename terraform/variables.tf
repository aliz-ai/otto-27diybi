variable "env" {
  type    = string
  default = "dev"
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "vpc_ip_range" {
  type        = string
  description = "VPC Subnet range"
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
variable "pattern_stop" {
}

variable "pattern_start" {
}

variable "label_key" {
}

variable "label_value" {
}

variable "scheduler_function_bucket" {
}

variable "timezone" {
}