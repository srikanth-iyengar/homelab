# Homelab Setup 🏡

Welcome to my homelab setup, managed with Terraform for infrastructure and Kubernetes for services! 🚀

## Overview 🌟

This setup deploys:
- [Jenkins](https://jenkins.srikanthk.in) 🛠️
- [Ntfy](https://ntfy.srikanthk.in) 📢
- [Grafana](https://grafana.srikanthk.in) 📈
- [Keycloak](https://keycloak.srikanthk.in) 🔐
- [BookStack](https://bookstack.srikanthk.in) 📚: A lightweight, self-hosted documentation platform for organizing and sharing information.
- [Firefly III](https://firefly.srikanthk.in) 💰: A personal finance manager for tracking expenses, budgeting, and financial planning.
- [Litmus Chaos](https://litmus.srikanthk.in) 🌀: A chaos engineering platform for Kubernetes. It helps you test the resilience of your applications by injecting chaos into your Kubernetes clusters. In this setup, we've deployed Litmus Chaos to enhance the reliability of our infrastructure.
- [SonarQube](https://sonar.srikanthk.in) 🔍: Static code analysis for your projects


And soon to come:
- [Kibana](https://kibana.srikanthk.in) 📈
- [Elasticsearch](https://elasticsearch.srikanthk.in) 📊
- [PgAdmin](https://pgadmin.srikanthk.in) 🐘
- [Heimdall](https://heimdall.srikanthk.in) 🗡️: A dashboard for managing all your web applications in one place.


## Prerequisites 📋

Before you begin:
- Kubernetes cluster up and running.
- Terraform installed.
- Cloudflare account for DNS.

## Get Started 🚀

1. Clone this repo:
   ```shell
   git clone https://github.com/srikanth-iyengar/infra.git
   cd infra
   ```
2. Install terraform and configure terraform.tfvars file
   ```hcl
   # terraform.tfvars

   cloudflare_zone        = "your_cloudflare_zone"
   cloudflare_zone_id     = "your_cloudflare_zone_id"
   cloudflare_account_id  = "your_cloudflare_account_id"
   cloudflare_email       = "your_cloudflare_email"
   cloudflare_token       = "your_cloudflare_token"
   supabase_db_url        = "your_supabase_db_url"
   supabase_db_host       = "your_supabase_db_host"
   supabase_db_password   = "your_supabase_db_password"
   supabase_db_username   = "your_supabase_db_username"
   keycloak_client_id     = "your_keycloak_client_id"
   keycloak_client_secret = "your_keycloak_client_secret"
   ```
3. Initialize the terraform state
   ```shell
   terraform init
   terraform plan -out myplan
   ```
4. Its terraform time, let the terraform create the infrastructure for you, meanwhile you grab a cup of coffee
   ```shell
   terraform apply
   ```
5. Make sure the you type yes and approve the plan or use -auto-approve flag
6. Take a coffee break and your homelab will be ready in couple of minutes.

## DNS Magic 🌐

✨ **Prepare to be amazed!** ✨

You might wonder how all these services are accessible, whether Kubernetes is running locally or in the cloud. 🤔

Well, here's the secret sauce: **Cloudflare Tunnel**! 🚀

With Cloudflare Tunnel, we've deployed all your services to a public network, making them accessible from anywhere in the world. Your homelab is now on the global stage! 🌍

But wait, there's more! 🎉

Ensure Cloudflare DNS is doing its job correctly, pointing to your services, and enjoy the magic! ✨

## Explore 🧐
Your services are live at:

For more services, customize Kubernetes manifests. 🛠️

Enjoy your homelab adventure! 🎉
