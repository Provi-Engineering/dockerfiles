#!/bin/bash

set -x

readonly GIT_SHA=$(git log --format=%h -1 .)
readonly GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
readonly ECR_REGISTRY="242369466814.dkr.ecr.us-east-2.amazonaws.com"
readonly ECR_IMAGE="${ECR_REGISTRY}/${PROJECT}:${GIT_SHA}"
readonly REGION="us-east-2"

cleanup() {
  popd
}
trap cleanup EXIT

build() {
  declare project="$1"

  pushd "$project"

  docker build --platform="linux/$(uname -m)" -t "${ECR_IMAGE}" .
  docker tag "${ECR_IMAGE}" "${ECR_REGISTRY}"/"${project}":latest
  docker push ${ECR_IMAGE}
  docker push ${ECR_REGISTRY}/${project}:latest
}

main() {
  aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

  for project in $(find . -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' -printf '%P\n'); do
    build "${project}"
  done
}

main
