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
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }

  }
  required_version = ">= 0.13"
}

terraform {
  backend "http" {
    address        = "https://api.tfstate.dev/github/v1"
    lock_address   = "https://api.tfstate.dev/github/v1/lock"
    unlock_address = "https://api.tfstate.dev/github/v1/lock"
    lock_method    = "PUT"
    unlock_method  = "DELETE"
    username       = "srikanth-iyengar/infra"
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "random" {
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "time" {
}
