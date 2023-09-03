terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.9.0"
    }
    random = {
      source = "hashicorp/random"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 0.13"
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "kubernetes" {
  config_path = "/home/srikanth/.kube/config"
}

provider "random" {
}
