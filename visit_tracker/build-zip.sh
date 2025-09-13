#!/usr/bin/env bash
set -x
set -euo pipefail
cd $(realpath $(dirname $0))
docker buildx build --platform linux/amd64 --load -t lambda:latest .
run_id=$(docker run -itd --rm lambda:latest)
docker cp $run_id:/usr/src/visit_tracker/target/lambda/visit_tracker/bootstrap.zip $1
docker rm --force $run_id