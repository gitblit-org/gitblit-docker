#!/bin/bash

IMAGE=$1

if [[ -z "${IMAGE}" ]] ; then
    echo "Usage: dgoss_run <docker image>"
    echo " "
    echo " Example: dgoss_run gitblit:snapshot"
    exit 1
fi

export GOSS_WAIT_OPTS="-r 60s -s 10s"

date
dgoss run  -e GITBLIT_GOSS_TEST=true -p 8080:8080  -p 8443:8443  ${IMAGE}
date