#!/bin/bash
set -euo pipefail
cd ${0%/*}/coffee-shop

trap cleanup EXIT

function cleanup() {
  # wipe local directory (will be populated from Docker image)
  sudo rm -Rf ./target/liberty/wlp/*

  docker stop coffee-shop coffee-shop-db barista &> /dev/null || true
}


cleanup

docker run -d --rm \
  --name coffee-shop-db \
  --network dkrnet \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  postgres:9.5

docker run -d --rm \
  --name barista \
  --network dkrnet \
  -p 8002:9080 \
  rodolpheche/wiremock:2.6.0 --port 9080

# running the usual container image, with the Docker volume location
docker run --rm \
  --name coffee-shop \
  --network dkrnet \
  -p 8001:9080 \
  -v liberty_dev_vol:/opt/wlp/ \
  coffee-shop
