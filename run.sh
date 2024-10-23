#!/usr/bin/env bash

docker build -t cubbit-nfs:latest . && docker run -it --privileged --rm \
    -v /mnt/nfs:/nfs \
    -e SHARED_DIRECTORY=/nfs \
    -p 2049:2049 \
    cubbit-nfs:latest
