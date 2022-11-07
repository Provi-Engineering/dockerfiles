#!/bin/bash

set -x

build() {
  declare project="$1"
  pushd "$project"
	make build
	popd
}

main() {
  for project in $(find . -mindepth 1 -maxdepth 1 -type d -not -path '*/.*' -printf '%P\n'); do
    build "${project}"
  done
}

main
