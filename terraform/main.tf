terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

provider "google" {
  project = "bouldercapacity"
  region  = "europe-west3"
  zone    = "europe-west3-a"
}

resource "google_storage_bucket" "raw_data" {
  name     = "bouldercapacity-raw-data-${var.environment}"
  location = "EU"
}

resource "google_storage_bucket" "crawler_code_bucket" {
  name     = "bouldercapacity-function-code-${var.environment}"
  location = "EU"
}

resource "google_storage_bucket_object" "crawler_code_archive" {
  name   = "crawler.zip"
  bucket = google_storage_bucket.crawler_code_bucket.name
  source = "../crawler.zip"
}

module "crawler-functions" {
  source       = "./crawler-function"
  for_each     = toset(var.crawler_names)
  name         = "${each.value}"
  environment = "${var.environment}"
  data_bucket  = google_storage_bucket.raw_data.name
  code_bucket  = google_storage_bucket.crawler_code_bucket.name
  code_archive = google_storage_bucket_object.crawler_code_archive.name
}