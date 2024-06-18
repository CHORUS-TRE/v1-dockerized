#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

docker run -ti --volume ./stage2-files:/root/stage2-files -v ./${pwd}/var-lib-docker:/var/lib/docker --entrypoint ./stage2-files/install.sh --privileged local/chorusv1-stage1
# export CONTAINER_ID=`docker ps -lq`
# docker commit $CONTAINER_ID local/chorusv1-stage2
