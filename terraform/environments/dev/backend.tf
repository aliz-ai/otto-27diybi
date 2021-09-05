terraform {
  backend "gcs" {
    bucket = "aliz-diybi-ia-tf-states"
    prefix = "env/test"
  }
}