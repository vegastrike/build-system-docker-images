#!/bin/bash

export FROM="cachyos/cachyos:latest"
export IS_RELEASE=0

#./script/cibuild
DOCKER_IMG_NAME="vegastrike/vega-strike-build-env:$(echo "$FROM" | sed 's/:/_/' | sed 's/\//_/')"
export DOCKER_IMG_NAME
docker build --build-arg from="$FROM" -t "$DOCKER_IMG_NAME" .
