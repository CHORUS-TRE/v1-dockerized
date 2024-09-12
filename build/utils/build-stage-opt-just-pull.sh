#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

docker run -ti --volume ./stage-opt-just-pull:/root/stage-opt-just-pull --entrypoint ./stage-opt-just-pull/install.sh --privileged local/chorusv1
export CONTAINER_ID=`docker ps -lq`
docker commit $CONTAINER_ID local/chorusv1
docker tag local/chorusv1 registry.build.chorus-tre.ch/chorusv1
