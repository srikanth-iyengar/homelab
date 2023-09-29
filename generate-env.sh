#!/bin/bash

source .env
[ -f terraform.tfvars ] && terraform.tfvars

HCP_API_TOKEN=`./get-api-token.sh`

secrets=$(curl -s \
    --location "https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJ_ID/apps/$APP_NAME/secrets" \
    --request GET \
    --header "Authorization: Bearer $HCP_API_TOKEN" | jq -r '.secrets[] .name')

for secret in $secrets; do
    value=$(curl -s \
    --location "https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJ_ID/apps/$APP_NAME/open/$secret" \
    --request GET \
    --header "Authorization: Bearer $HCP_API_TOKEN" | jq '.secret .version .value')
    echo $secret=$value >> terraform.tfvars
done

