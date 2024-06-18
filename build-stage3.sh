#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

docker run -ti --volume ./stage3-files:/root/stage3-files --entrypoint ./stage3-files/install.sh --privileged local/chorusv1-stage1
export CONTAINER_ID=`docker ps -lq`
docker commit $CONTAINER_ID local/chorusv1-stage3
docker tag local/chorusv1-stage3 registry.build.chorus-tre.ch/chorusv1-stage3
