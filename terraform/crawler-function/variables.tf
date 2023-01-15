variable "name" {
  type     = string
  nullable = false
}

variable "environment" {
  type     = string
  nullable = false
}

variable "data_bucket" {
  type     = string
  nullable = false
}

variable "code_bucket" {
  type     = string
  nullable = false
}

variable "code_archive" {
  type     = string
  nullable = false
}