variable "cloudflare_zone" {
  description = "Domain used to expose the GCP VM instance to the Internet"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for your domain"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email address for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Cloudflare API token created at https://dash.cloudflare.com/profile/api-tokens"
  type        = string
  sensitive   = true
}

variable "supabase_db_host" {
  description = "Host for the postgresdb"
  type        = string
  sensitive   = true
}

variable "supabase_db_password" {
  description = "Password for supbase postgresdb"
  type        = string
  sensitive   = true
}

variable "supabase_db_username" {
  description = "Postgres db username"
  type        = string
  sensitive   = true
}

variable "supabase_db_url" {
  description = "Connection url for the postgres"
  type        = string
  sensitive   = true
}


