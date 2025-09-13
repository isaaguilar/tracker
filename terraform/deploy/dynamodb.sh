#!/usr/bin/env bash 
set -x
set -euo pipefail
dir=$(realpath $(dirname $0))
cd "$dir/../modules/dynamodb/"
terraform init -backend-config ../../environments/dynamodb/visit_tracker.key
terraform plan -var-file ../../environments/dynamodb/visit_tracker.tfvars -out plan.out
terraform apply plan.out