#!/usr/bin/env bash 
set -x
set -euo pipefail
dir=$(realpath $(dirname $0))
cd "$dir"
# Get the zip file
mkdir -p "$dir/dist"
bash "$dir/../../visit_tracker/build-zip.sh" "$dir/dist/"

cd "$dir/../modules/lambda/"
terraform init -backend-config ../../environments/lambda/visit_tracker.key

export TF_VAR_lambda_package_path=$dir/dist/bootstrap.zip
terraform plan -var-file ../../environments/lambda/visit_tracker.tfvars -out plan.out
terraform apply plan.out
