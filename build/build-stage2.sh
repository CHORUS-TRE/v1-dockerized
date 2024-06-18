#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

docker run -ti --volume ./stage2-files:/root/stage2-files --entrypoint ./stage2-files/install.sh --privileged local/chorusv1-stage1
export CONTAINER_ID=`docker ps -lq`
docker commit $CONTAINER_ID local/chorusv1
docker tag local/chorusv1 registry.build.chorus-tre.ch/chorusv1
