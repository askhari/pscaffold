terraform {
  required_version = ">= 1.9"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.107"
    }
  }

  # DigitalOcean Spaces (S3-compatible). Bucket, key and endpoint come from backend.hcl.
  backend "s3" {}
}

provider "digitalocean" {}
