#!/bin/bash

set -e

tarantool_version=${TARANTOOL_VERSION:-opensource-1.10}
dockerfile_suffix=opensource

if [[ $tarantool_version == "enterprise" ]] ;
then
    dockerfile_suffix=enterprise
fi

if [[ $tarantool_version == "opensource-2.2" ]] ;
then
    tarantool_repo=tarantool/2_2
elif [[ $tarantool_version == "opensource-1.10" ]] ;
then
    tarantool_repo=tarantool/1_10
fi

image=${tarantool_version}-packages-builder
container=${image}-container

echo "Build packages for ${tarantool_version}"

docker rm ${container} || true

docker build --build-arg TARANTOOL_DOWNLOAD_TOKEN=${TARANTOOL_DOWNLOAD_TOKEN} \
             --build-arg BUNDLE_VERSION=${BUNDLE_VERSION} \
             --build-arg TARANTOOL_REPO=${tarantool_repo} \
             -t ${image} \
             -f Dockerfile.${dockerfile_suffix} \
             -t ${image} .

docker create --name ${container} ${image} usr/bin/true
docker cp ${container}:/opt/myapp/myapp-1.0.0-0.rpm .
docker cp ${container}:/opt/myapp/myapp-1.0.0-0.deb .
docker rm ${container}
