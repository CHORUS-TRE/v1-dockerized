#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

# docker run -ti --volume ./stage3-files:/root/stage3-files --volume ./docker-data:/var/lib/docker --entrypoint ./stage3-files/install.sh --privileged local/chorusv1-stage2
docker run -ti --volume ./stage3-files:/root/stage3-files -v $(pwd)/var-lib-docker:/var/lib/docker --entrypoint ./stage3-files/install.sh --privileged local/chorusv1-stage2
export CONTAINER_ID=`docker ps -lq`
docker commit $CONTAINER_ID local/chorusv1-stage3

