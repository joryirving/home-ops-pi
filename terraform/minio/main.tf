locals {
  buckets = [
    "longhorn",
    "postgresql",
    "thanos"
  ]
}

terraform {
  required_providers {
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">= 0.6.0"
    }

    minio = {
      source  = "aminueza/minio"
      version = "1.16.0"
    }
  }
}

module "secrets_s3" {
  source = "./modules/get-secret"
  id     = "5a98804c-6c54-4e09-817e-afd8012c70ad"
}
