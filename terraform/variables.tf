variable "environment" {
  type     = string
  nullable = false
}

variable "crawler_names" {
  type = list(string)
}