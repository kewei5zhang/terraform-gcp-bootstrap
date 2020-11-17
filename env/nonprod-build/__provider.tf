provider "google-beta" {
    region = var.region
    version = ">= 2.9.0"
}

provider "google" {
    region = var.region
    version = ">= 2.0.0"
}