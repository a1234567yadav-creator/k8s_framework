terraform {
  backend "gcs" {
    bucket = "<your-gcs-bucket>"
    prefix = "state/dev-gke"
  }
}
