variable "project" {
  type        = string
}
variable "region" {
  type        = string
}

provider "google" {
  version = "3.25.0"

  project = var.project
  region  = var.region
}

resource "google_cloudfunctions_function" "test" {
    name                      = "my-hello-function"
    runtime     = "nodejs10"
    entry_point               = "helloGET"
    available_memory_mb       = 128
    timeout                   = 61
    project                   = var.project
    region                    = var.region
    trigger_http              = true
    source_archive_bucket     = google_storage_bucket.bucket.name
    source_archive_object     = google_storage_bucket_object.archive.name
}

resource "google_storage_bucket" "bucket" {
  name = "dve-cloudfunction-deploy-test1"
}

data "archive_file" "http_trigger" {
  type        = "zip"
  output_path = "${path.module}/function.zip"
  source {
    content  = "${file("${path.module}/sample-code/index.js")}"
    filename = "index.js"
  }
}

resource "google_storage_bucket_object" "archive" {
  name   = "http_trigger.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${path.module}/function.zip"
  depends_on = [data.archive_file.http_trigger]
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.test.project
  region         = google_cloudfunctions_function.test.region
  cloud_function = google_cloudfunctions_function.test.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}