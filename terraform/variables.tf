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
