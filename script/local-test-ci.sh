#!/bin/bash

export FROM="dokken/centos-stream-10:main"
export MY_OS_NAME="linux"
export IS_RELEASE=0

#./script/cibuild
export DOCKER_IMG_NAME="vegastrike/vega-strike-build-env:$(echo "$FROM" | sed 's/:/_/' | sed 's/\//_/')"
docker build --build-arg from="$FROM" -t "$DOCKER_IMG_NAME" .
