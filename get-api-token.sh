#!/bin/bash

source .env
HCP_API_TOKEN=$(curl -s --location 'https://auth.hashicorp.com/oauth/token' \
     --header 'content-type: application/json' \
     --data '{
         "audience": "https://api.hashicorp.cloud",
         "grant_type": "client_credentials",
         "client_id": "'$HCP_CLIENT_ID'",
         "client_secret": "'$HCP_CLIENT_SECRET'"
     }' | jq -r .access_token)
echo $HCP_API_TOKEN
